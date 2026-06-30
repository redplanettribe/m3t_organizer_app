import 'dart:async';

import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m3t_organizer/features/chat/bloc/organizers_chat_cubit.dart';
import 'package:m3t_organizer/features/chat/view/open_attendee_registration.dart';
import 'package:m3t_organizer/features/chat/widgets/widgets.dart';

final class OrganizersChatView extends StatelessWidget {
  const OrganizersChatView({
    required this.eventID,
    this.currentUserId,
    super.key,
  });

  final String eventID;
  final String? currentUserId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OrganizersChatCubit(
        chatRepository: context.read<ChatRepository>(),
        eventID: eventID,
        currentUserId: currentUserId,
      ),
      child: BlocListener<OrganizersChatCubit, OrganizersChatState>(
        listenWhen: (previous, current) =>
            previous.errorMessage != current.errorMessage &&
            current.errorMessage != null,
        listener: (context, state) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                behavior: SnackBarBehavior.floating,
              ),
            );
        },
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: _OrganizersMessageList()),
            _OrganizersComposer(),
          ],
        ),
      ),
    );
  }
}

final class _OrganizersMessageList extends StatefulWidget {
  const _OrganizersMessageList();

  @override
  State<_OrganizersMessageList> createState() => _OrganizersMessageListState();
}

final class _OrganizersMessageListState extends State<_OrganizersMessageList> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 48) {
      unawaited(context.read<OrganizersChatCubit>().loadOlder());
    }
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cubit = context.read<OrganizersChatCubit>();

    return BlocBuilder<OrganizersChatCubit, OrganizersChatState>(
      builder: (context, state) {
        if (state.status == OrganizersChatStatus.loading &&
            state.messages.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.status == OrganizersChatStatus.failure &&
            state.messages.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  state.errorMessage ?? 'Could not load team chat.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: cubit.loadInitial,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state.messages.isEmpty) {
          return Center(
            child: Text(
              'No messages yet. Say hello to the team.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          );
        }

        return ListView.builder(
          controller: _scrollController,
          reverse: true,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          itemCount: state.messages.length + (state.loadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (state.loadingMore && index == state.messages.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Center(
                  child: SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              );
            }

            final messageIndex = state.messages.length - 1 - index;
            final message = state.messages[messageIndex];
            final isOwn = cubit.isOwnMessage(message);
            final previous =
                messageIndex > 0 ? state.messages[messageIndex - 1] : null;

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
                messageID: message.messageId,
                emoji: emoji,
              ),
              onReply: () => cubit.startReply(message),
              onDelete: isOwn
                  ? () => cubit.deleteOwnMessage(message.messageId)
                  : null,
            );
          },
        );
      },
    );
  }
}

final class _OrganizersComposer extends StatefulWidget {
  const _OrganizersComposer();

  @override
  State<_OrganizersComposer> createState() => _OrganizersComposerState();
}

final class _OrganizersComposerState extends State<_OrganizersComposer> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sending = context.select<OrganizersChatCubit, bool>(
      (c) => c.state.sending,
    );
    final replyingTo = context.select<OrganizersChatCubit, ChatMessage?>(
      (c) => c.state.replyingTo,
    );

    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (replyingTo != null)
            ReplyComposerBanner(
              message: replyingTo,
              onCancel: () =>
                  context.read<OrganizersChatCubit>().cancelReply(),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    minLines: 1,
                    maxLines: 4,
                    textInputAction: TextInputAction.send,
                    decoration: InputDecoration(
                      hintText: replyingTo != null
                          ? 'Reply…'
                          : 'Message organizers…',
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                    onSubmitted: _send,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: sending ? null : () => _send(_controller.text),
                  icon: sending
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send_rounded),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _send(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    unawaited(context.read<OrganizersChatCubit>().sendMessage(trimmed));
    _controller.clear();
  }
}
