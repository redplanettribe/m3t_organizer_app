import 'dart:async';

import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m3t_organizer/features/chat/general/bloc/general_chat_cubit.dart';
import 'package:m3t_organizer/features/chat/view/open_attendee_registration.dart';
import 'package:m3t_organizer/features/chat/widgets/widgets.dart';

final class GeneralChatTab extends StatelessWidget {
  const GeneralChatTab({required this.eventID, super.key});

  final String eventID;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GeneralChatCubit(
        chatRepository: context.read<ChatRepository>(),
        authRepository: context.read<AuthRepository>(),
        eventID: eventID,
      ),
      child: const GeneralChatView(),
    );
  }
}

final class GeneralChatView extends StatelessWidget {
  const GeneralChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GeneralChatCubit, GeneralChatState>(
      listenWhen: (previous, current) =>
          previous.errorMessage != current.errorMessage &&
          current.errorMessage != null,
      listener: (context, state) {
        final message = state.errorMessage;
        if (message == null) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
        context.read<GeneralChatCubit>().clearError();
      },
      builder: (context, state) {
        return switch (state.status) {
          GeneralChatStatus.initial ||
          GeneralChatStatus.loading => const Center(
            child: CircularProgressIndicator(),
          ),
          GeneralChatStatus.failure => _ErrorBody(
            message: state.errorMessage ?? 'Could not load chat.',
            onRetry: () => context.read<GeneralChatCubit>().initialize(),
          ),
          GeneralChatStatus.ready => _ReadyBody(state: state),
        };
      },
    );
  }
}

final class _ReadyBody extends StatefulWidget {
  const _ReadyBody({required this.state});

  final GeneralChatState state;

  @override
  State<_ReadyBody> createState() => _ReadyBodyState();
}

final class _ReadyBodyState extends State<_ReadyBody> {
  final _composerController = TextEditingController();

  @override
  void dispose() {
    _composerController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _composerController.text;
    if (text.trim().isEmpty) return;
    _composerController.clear();
    unawaited(context.read<GeneralChatCubit>().sendMessage(text));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.state.loadingMore)
          const LinearProgressIndicator(minHeight: 2),
        Expanded(child: _MessageList(state: widget.state)),
        _Composer(
          controller: _composerController,
          sending: widget.state.sending,
          replyingTo: widget.state.replyingTo,
          onCancelReply: () => context.read<GeneralChatCubit>().cancelReply(),
          onSend: _sendMessage,
        ),
      ],
    );
  }
}

final class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

final class _MessageList extends StatefulWidget {
  const _MessageList({required this.state});

  final GeneralChatState state;

  @override
  State<_MessageList> createState() => _MessageListState();
}

final class _MessageListState extends State<_MessageList> {
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
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 64) {
      unawaited(context.read<GeneralChatCubit>().loadOlderMessages());
    }
  }

  @override
  Widget build(BuildContext context) {
    final messages = widget.state.messages;
    if (messages.isEmpty) {
      return const Center(child: Text('No messages yet. Say hello!'));
    }

    final cubit = context.read<GeneralChatCubit>();

    return ListView.builder(
      controller: _scrollController,
      reverse: true,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final messageIndex = messages.length - 1 - index;
        final message = messages[messageIndex];
        final isOwn = message.senderUserId == widget.state.currentUserId;
        final previous =
            messageIndex > 0 ? messages[messageIndex - 1] : null;
        return ChatMessageBubble(
          message: message,
          isOwn: isOwn,
          showSenderHeader: showSenderHeaderForMessage(
            message: message,
            chronologicallyPreviousMessage: previous,
          ),
          onSenderTap: isOwn
              ? null
              : () => openAttendeeRegistration(
                  context,
                  eventID: message.eventId,
                  message: message,
                ),
          onReact: (emoji) => cubit.toggleReaction(
            messageId: message.messageId,
            emoji: emoji,
          ),
          onReply: () => cubit.startReply(message),
          onDelete: isOwn
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
    final theme = Theme.of(context);
    return Material(
      elevation: 4,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (replyingTo != null)
              ReplyComposerBanner(
                message: replyingTo!,
                onCancel: onCancelReply,
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => onSend(),
                      decoration: InputDecoration(
                        hintText: replyingTo != null
                            ? 'Reply…'
                            : 'Message everyone…',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton.filled(
                    onPressed: sending ? null : onSend,
                    icon: sending
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: theme.colorScheme.onPrimary,
                            ),
                          )
                        : const Icon(Icons.send_rounded),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
