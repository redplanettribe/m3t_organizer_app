import 'package:domain/domain.dart';
import 'package:flutter/material.dart';

/// Reply preview banner shown above the message composer.
final class ReplyComposerBanner extends StatelessWidget {
  const ReplyComposerBanner({
    required this.message,
    required this.onCancel,
    super.key,
  });

  final ChatMessage message;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final senderLabel = [
      message.senderName,
      message.senderLastName,
    ].whereType<String>().where((s) => s.isNotEmpty).join(' ');

    return Material(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 44,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    senderLabel.isNotEmpty ? senderLabel : 'Message',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    message.body,
                    style: theme.textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Cancel reply',
              onPressed: onCancel,
              icon: const Icon(Icons.close),
            ),
          ],
        ),
      ),
    );
  }
}
