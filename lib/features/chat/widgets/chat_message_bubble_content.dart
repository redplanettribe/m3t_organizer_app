import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:m3t_organizer/features/chat/widgets/chat_reply_preview.dart';

/// Inner content of a chat bubble (shared by list item and overlay replica).
final class ChatMessageBubbleContent extends StatelessWidget {
  const ChatMessageBubbleContent({
    required this.message,
    required this.isOwn,
    required this.showSenderName,
    super.key,
  });

  final ChatMessage message;
  final bool isOwn;
  final bool showSenderName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final senderLabel = [
      message.senderName,
      message.senderLastName,
    ].whereType<String>().where((s) => s.isNotEmpty).join(' ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showSenderName && !isOwn && senderLabel.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              senderLabel,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        if (message.replyTo != null) ...[
          ChatReplyPreview(replyTo: message.replyTo!),
          const SizedBox(height: 4),
        ],
        Text(message.body),
        const SizedBox(height: 4),
        Text(
          DateFormat.jm().format(message.createdAt.toLocal()),
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
