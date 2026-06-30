import 'package:domain/domain.dart';
import 'package:flutter/material.dart';

/// WhatsApp-style overlapping reaction pills anchored to a bubble edge.
final class ChatMessageReactions extends StatelessWidget {
  const ChatMessageReactions({
    required this.reactions,
    required this.isOwn,
    required this.onReactionTap,
    super.key,
  });

  final List<ChatReaction> reactions;
  final bool isOwn;
  final ValueChanged<String> onReactionTap;

  @override
  Widget build(BuildContext context) {
    if (reactions.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    const pillWidth = 36.0;
    const overlap = 10.0;
    final totalWidth =
        pillWidth + (reactions.length - 1) * (pillWidth - overlap);

    return SizedBox(
      height: 28,
      width: totalWidth,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (var i = 0; i < reactions.length; i++)
            Positioned(
              left: isOwn ? null : i * (pillWidth - overlap),
              right: isOwn ? i * (pillWidth - overlap) : null,
              bottom: 0,
              child: _ReactionPill(
                reaction: reactions[i],
                theme: theme,
                onTap: () => onReactionTap(reactions[i].emoji),
              ),
            ),
        ],
      ),
    );
  }
}

final class _ReactionPill extends StatelessWidget {
  const _ReactionPill({
    required this.reaction,
    required this.theme,
    required this.onTap,
  });

  final ChatReaction reaction;
  final ThemeData theme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 1,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(14),
      color: reaction.reactedByMe
          ? theme.colorScheme.primaryContainer
          : theme.colorScheme.surface,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: reaction.reactedByMe
                  ? theme.colorScheme.primary.withValues(alpha: 0.4)
                  : theme.colorScheme.outlineVariant,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(reaction.emoji, style: const TextStyle(fontSize: 14)),
              if (reaction.count > 1) ...[
                const SizedBox(width: 2),
                Text(
                  '${reaction.count}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
