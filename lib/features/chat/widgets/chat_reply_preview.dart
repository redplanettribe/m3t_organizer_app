import 'package:domain/domain.dart';
import 'package:flutter/material.dart';

/// Quoted reply preview inside a message bubble.
final class ChatReplyPreview extends StatelessWidget {
  const ChatReplyPreview({required this.replyTo, super.key});

  final ChatReplyTo replyTo;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = [
      replyTo.senderName,
      replyTo.senderLastName,
    ].whereType<String>().where((s) => s.isNotEmpty).join(' ');

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(
            color: theme.colorScheme.primary,
            width: 3,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label.isNotEmpty)
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
          Text(
            replyTo.deleted ? 'Message deleted' : (replyTo.body ?? ''),
            style: theme.textTheme.bodySmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
