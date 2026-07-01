import 'dart:async';

import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m3t_organizer/core/push/chat_push_dedupe.dart';
import 'package:m3t_organizer/core/push/push_notification_cubit.dart';
import 'package:m3t_organizer/features/chat/bloc/chat_cubit.dart';
import 'package:m3t_organizer/features/chat/bloc/chat_unread_cubit.dart';
import 'package:m3t_organizer/features/chat/bloc/dm_thread_cubit.dart';
import 'package:m3t_organizer/features/chat/widgets/widgets.dart';

final class DmThreadPage extends StatefulWidget {
  const DmThreadPage({
    required this.eventID,
    required this.recipientUserId,
    required this.currentUserId,
    this.recipientDisplayName,
    super.key,
  });

  final String eventID;
  final String recipientUserId;
  final String currentUserId;
  final String? recipientDisplayName;

  @override
  State<DmThreadPage> createState() => _DmThreadPageState();
}

final class _DmThreadPageState extends State<DmThreadPage> {
  PushNotificationCubit? _pushNotificationCubit;
  ChatUnreadCubit? _chatUnreadCubit;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _pushNotificationCubit = context.read<PushNotificationCubit>();
    try {
      _chatUnreadCubit = context.read<ChatUnreadCubit>();
    } on Object {
      _chatUnreadCubit = null;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final conversationId = dmConversationId(
        eventId: widget.eventID,
        userIdA: widget.currentUserId,
        userIdB: widget.recipientUserId,
      );
      _pushNotificationCubit?.setOpenDmThread(
        eventId: widget.eventID,
        conversationId: conversationId,
      );
      _chatUnreadCubit
        ?..setOpenDmConversation(conversationId)
        ..markDmConversationRead(conversationId);
    });
  }

  @override
  void dispose() {
    _pushNotificationCubit?.setOpenDmThread();
    _chatUnreadCubit?.setOpenDmConversation(null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatCubit = context.read<ChatCubit>();

    return BlocProvider(
      create: (context) => DmThreadCubit(
        chatRepository: context.read<ChatRepository>(),
        eventID: widget.eventID,
        recipientUserId: widget.recipientUserId,
        currentUserId: widget.currentUserId,
        realtimeEvents: chatCubit.realtimeEvents,
        recipientDisplayName: widget.recipientDisplayName,
        onMessageDeliveredViaRealtime: rememberChatMessageForPush(context),
      ),
      child: _DmThreadView(currentUserId: widget.currentUserId),
    );
  }
}

final class _DmThreadView extends StatefulWidget {
  const _DmThreadView({required this.currentUserId});

  final String currentUserId;

  @override
  State<_DmThreadView> createState() => _DmThreadViewState();
}

final class _DmThreadViewState extends State<_DmThreadView> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    _textController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.pixels <= 48) {
      unawaited(context.read<DmThreadCubit>().loadOlderMessages());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DmThreadCubit, DmThreadState>(
      listenWhen: (prev, next) =>
          prev.messages.length != next.messages.length ||
          prev.errorMessage != next.errorMessage,
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        }
        if (state.messages.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients) {
              _scrollController.jumpTo(
                _scrollController.position.maxScrollExtent,
              );
            }
          });
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(state.recipientDisplayName),
          ),
          body: Column(
            children: [
              if (state.loadingMore)
                const LinearProgressIndicator(minHeight: 2),
              Expanded(
                child: _MessageList(
                  state: state,
                  currentUserId: widget.currentUserId,
                  scrollController: _scrollController,
                ),
              ),
              _Composer(
                controller: _textController,
                sending: state.sending,
                replyingTo: state.replyingTo,
                onCancelReply: () =>
                    context.read<DmThreadCubit>().cancelReply(),
                onSend: () {
                  final text = _textController.text;
                  _textController.clear();
                  unawaited(context.read<DmThreadCubit>().sendMessage(text));
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

final class _MessageList extends StatelessWidget {
  const _MessageList({
    required this.state,
    required this.currentUserId,
    required this.scrollController,
  });

  final DmThreadState state;
  final String currentUserId;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    if (state.loading && state.messages.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.messages.isEmpty) {
      return const Center(child: Text('Say hello'));
    }

    final cubit = context.read<DmThreadCubit>();

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.all(12),
      itemCount: state.messages.length,
      itemBuilder: (context, index) {
        final message = state.messages[index];
        final isMine = message.senderUserId == currentUserId;
        return ChatMessageBubble(
          message: message,
          isOwn: isMine,
          showSenderHeader: false,
          onReact: (emoji) => cubit.toggleReaction(
            messageId: message.messageId,
            emoji: emoji,
          ),
          onReply: () => cubit.startReply(message),
          onDelete: isMine
              ? () => cubit.deleteMessage(message.messageId)
              : null,
        );
      },
    );
  }
}

final class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.sending,
    required this.onSend,
    required this.onCancelReply,
    this.replyingTo,
  });

  final TextEditingController controller;
  final bool sending;
  final VoidCallback onSend;
  final VoidCallback onCancelReply;
  final ChatMessage? replyingTo;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (replyingTo != null)
            ReplyComposerBanner(
              message: replyingTo!,
              onCancel: onCancelReply,
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    minLines: 1,
                    maxLines: 4,
                    textInputAction: TextInputAction.send,
                    onSubmitted: sending ? null : (_) => onSend(),
                    decoration: InputDecoration(
                      hintText: replyingTo != null ? 'Reply…' : 'Message',
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: sending ? null : onSend,
                  icon: sending
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
