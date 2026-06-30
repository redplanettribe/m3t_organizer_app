import 'dart:async';

import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:m3t_organizer/features/chat/bloc/chat_cubit.dart';
import 'package:m3t_organizer/features/chat/bloc/dm_inbox_cubit.dart';
import 'package:m3t_organizer/features/chat/view/dm_thread_page.dart';

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
    final last = conversation.lastMessage;
    final displayName = last == null
        ? conversation.otherUserId
        : _senderLabel(last, conversation.otherUserId);
    final chatCubit = context.read<ChatCubit>();

    unawaited(
      Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (context) => BlocProvider.value(
            value: chatCubit,
            child: DmThreadPage(
              eventID: eventID,
              recipientUserId: conversation.otherUserId,
              currentUserId: currentUserId,
              recipientDisplayName: displayName,
            ),
          ),
        ),
      ),
    );
  }

  static String _senderLabel(ChatMessage message, String fallbackUserId) {
    final name = [
      message.senderName,
      message.senderLastName,
    ].whereType<String>().where((s) => s.trim().isNotEmpty).join(' ');
    return name.isEmpty ? fallbackUserId : name;
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
    final title = last == null
        ? conversation.otherUserId
        : (last.senderUserId == currentUserId
              ? 'You'
              : DmInboxView._senderLabel(last, conversation.otherUserId));

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
      trailing: time.isEmpty
          ? null
          : Text(
              time,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
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
