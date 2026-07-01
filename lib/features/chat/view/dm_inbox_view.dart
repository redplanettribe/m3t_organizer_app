import 'dart:async';

import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:m3t_organizer/features/chat/bloc/chat_unread_cubit.dart';
import 'package:m3t_organizer/features/chat/bloc/dm_inbox_cubit.dart';
import 'package:m3t_organizer/features/chat/view/open_dm_thread.dart';
import 'package:m3t_organizer/features/chat/widgets/unread_badge_label.dart';

final class DmInboxView extends StatelessWidget {
  const DmInboxView({
    required this.eventID,
    required this.currentUserId,
    super.key,
  });

  final String eventID;
  final String currentUserId;

  @override
  Widget build(BuildContext context) {
    return BlocListener<DmInboxCubit, DmInboxState>(
      listenWhen: (previous, current) =>
          previous.errorMessage != current.errorMessage &&
          current.errorMessage != null &&
          current.conversations.isNotEmpty,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _DmInboxToolbar(
            eventID: eventID,
            currentUserId: currentUserId,
          ),
          Expanded(
            child: _DmInboxBody(
              eventID: eventID,
              currentUserId: currentUserId,
            ),
          ),
        ],
      ),
    );
  }
}

final class _DmInboxToolbar extends StatelessWidget {
  const _DmInboxToolbar({
    required this.eventID,
    required this.currentUserId,
  });

  final String eventID;
  final String currentUserId;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 4),
      child: Row(
        children: [
          Text(
            'Direct messages',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const Spacer(),
          IconButton(
            tooltip: 'New message',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _showNewDmSheet(context),
          ),
        ],
      ),
    );
  }

  Future<void> _showNewDmSheet(BuildContext context) async {
    final cubit = context.read<DmInboxCubit>();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return BlocProvider.value(
          value: cubit,
          child: _NewDmSheet(
            eventID: eventID,
            currentUserId: currentUserId,
          ),
        );
      },
    );
  }
}

final class _DmInboxBody extends StatelessWidget {
  const _DmInboxBody({
    required this.eventID,
    required this.currentUserId,
  });

  final String eventID;
  final String currentUserId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DmInboxCubit, DmInboxState>(
      builder: (context, state) {
        if (state.loading && state.conversations.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.errorMessage != null && state.conversations.isEmpty) {
          return _ErrorBody(
            message: state.errorMessage!,
            onRetry: () => context.read<DmInboxCubit>().loadConversations(),
          );
        }

        if (state.conversations.isEmpty) {
          return const Center(child: Text('No direct messages yet'));
        }

        return RefreshIndicator(
          onRefresh: () =>
              context.read<DmInboxCubit>().loadConversations(silent: true),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount:
                state.conversations.length + (state.nextCursor != null ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= state.conversations.length) {
                return _LoadMoreTile(
                  loading: state.loadingMore,
                  onLoadMore: () =>
                      context.read<DmInboxCubit>().loadMoreConversations(),
                );
              }

              final conversation = state.conversations[index];
              return _ConversationTile(
                conversation: conversation,
                currentUserId: currentUserId,
                onTap: () => _openThread(context, conversation),
              );
            },
          ),
        );
      },
    );
  }

  void _openThread(BuildContext context, ChatConversation conversation) {
    openDmThread(
      context,
      eventID: eventID,
      recipientUserId: conversation.otherUserId,
      currentUserId: currentUserId,
      recipientDisplayName: conversation.displayTitle,
    );
  }
}

final class _NewDmSheet extends StatefulWidget {
  const _NewDmSheet({
    required this.eventID,
    required this.currentUserId,
  });

  final String eventID;
  final String currentUserId;

  @override
  State<_NewDmSheet> createState() => _NewDmSheetState();
}

final class _NewDmSheetState extends State<_NewDmSheet> {
  final _searchController = TextEditingController();
  Timer? _debounce;
  List<EventRegistration> _results = const [];
  bool _searching = false;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () async {
      if (!mounted) return;
      setState(() => _searching = true);
      final results = await context.read<DmInboxCubit>().searchAttendees(
        value,
      );
      if (!mounted) return;
      setState(() {
        _results = results;
        _searching = false;
      });
    });
  }

  void _openThread(EventRegistration registration) {
    openDmThread(
      context,
      eventID: widget.eventID,
      recipientUserId: registration.userId,
      currentUserId: widget.currentUserId,
      recipientDisplayName: registration.displayName,
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'New message',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _searchController,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Search by name or email',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            onChanged: _onSearchChanged,
          ),
          const SizedBox(height: 12),
          if (_searching)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_searchController.text.trim().isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(
                'Type to search registered attendees.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            )
          else if (_results.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(
                'No attendees match your search.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            )
          else
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * 0.4,
              ),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _results.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final registration = _results[index];

                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(registration.displayName),
                    subtitle: Text(
                      registration.email ?? registration.userId,
                      style: theme.textTheme.bodySmall,
                    ),
                    onTap: () => _openThread(registration),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

final class _ConversationTile extends StatelessWidget {
  const _ConversationTile({
    required this.conversation,
    required this.currentUserId,
    required this.onTap,
  });

  final ChatConversation conversation;
  final String currentUserId;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final last = conversation.lastMessage;
    final preview = last?.body ?? 'No messages yet';
    final time = last != null ? _formatTime(last.createdAt) : '';
    final title = conversation.displayTitle;

    return BlocBuilder<ChatUnreadCubit, ChatUnreadState>(
      builder: (context, unreadState) {
        final unreadCount = unreadState.dmUnreadFor(
          conversation.conversationId,
        );
        final trailing = _ConversationTrailing(
          time: time,
          unreadCount: unreadCount,
          theme: theme,
        );

        return ListTile(
          onTap: onTap,
          title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text(
            preview,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          trailing: trailing,
        );
      },
    );
  }

  String _formatTime(DateTime createdAt) {
    final now = DateTime.now();
    if (now.difference(createdAt).inDays == 0) {
      return DateFormat.jm().format(createdAt);
    }
    return DateFormat.MMMd().format(createdAt);
  }
}

final class _ConversationTrailing extends StatelessWidget {
  const _ConversationTrailing({
    required this.time,
    required this.unreadCount,
    required this.theme,
  });

  final String time;
  final int unreadCount;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    if (time.isEmpty && unreadCount == 0) {
      return const SizedBox.shrink();
    }

    final timeStyle = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    if (unreadCount == 0) {
      return Text(time, style: timeStyle);
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (time.isNotEmpty) Text(time, style: timeStyle),
        if (time.isNotEmpty) const SizedBox(height: 4),
        unreadBadge(
          count: unreadCount,
          child: const SizedBox(width: 8, height: 8),
        ),
      ],
    );
  }
}

final class _LoadMoreTile extends StatelessWidget {
  const _LoadMoreTile({
    required this.loading,
    required this.onLoadMore,
  });

  final bool loading;
  final VoidCallback onLoadMore;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Center(
      child: TextButton(
        onPressed: onLoadMore,
        child: const Text('Load more'),
      ),
    );
  }
}

final class _ErrorBody extends StatelessWidget {
  const _ErrorBody({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
