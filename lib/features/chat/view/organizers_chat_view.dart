import 'dart:async';

import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m3t_organizer/features/chat/bloc/organizers_chat_cubit.dart';
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
            _OrganizersChatToolbar(),
            Expanded(child: _OrganizersMessageList()),
            _OrganizersComposer(),
          ],
        ),
      ),
    );
  }
}

final class _OrganizersChatToolbar extends StatelessWidget {
  const _OrganizersChatToolbar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 4),
      child: Row(
        children: [
          Text(
            'Backstage',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const Spacer(),
          IconButton(
            tooltip: 'Delete general message',
            icon: const Icon(Icons.gavel_outlined),
            onPressed: () => _showDeleteGeneralDialog(context),
          ),
          IconButton(
            tooltip: 'Chat bans',
            icon: const Icon(Icons.block_outlined),
            onPressed: () => _showBansSheet(context),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteGeneralDialog(BuildContext context) async {
    final controller = TextEditingController();
    final cubit = context.read<OrganizersChatCubit>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete general message'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Message ID',
            hintText: 'UUID of general chat message',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      if (!context.mounted) return;
      try {
        await cubit.deleteGeneralMessage(controller.text);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('General message deleted'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } on Object {
        // Error surfaced via BlocListener.
      }
    }
    controller.dispose();
  }

  Future<void> _showBansSheet(BuildContext context) async {
    final cubit = context.read<OrganizersChatCubit>();
    await cubit.loadBans();
    if (!context.mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return BlocProvider.value(
          value: cubit,
          child: const _ChatBansSheet(),
        );
      },
    );
  }
}

final class _ChatBansSheet extends StatelessWidget {
  const _ChatBansSheet();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<OrganizersChatCubit, OrganizersChatState>(
      builder: (context, state) {
        if (state.loadingBans) {
          return const SizedBox(
            height: 160,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (state.bans.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'No chat bans for this event.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          itemCount: state.bans.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final ban = state.bans[index];
            final name = [
              ban.userName,
              ban.userLastName,
            ].whereType<String>().where((s) => s.isNotEmpty).join(' ');
            final label = name.isNotEmpty ? name : ban.userId;

            return ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(label),
              subtitle: Text(ban.userId, style: theme.textTheme.bodySmall),
              trailing: IconButton(
                tooltip: 'Unban',
                icon: const Icon(Icons.undo_outlined),
                onPressed: () =>
                    context.read<OrganizersChatCubit>().unbanUser(ban.userId),
              ),
            );
          },
        );
      },
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
                  state.errorMessage ?? 'Could not load backstage chat.',
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

            return ChatMessageBubble(
              message: message,
              isOwn: isOwn,
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
