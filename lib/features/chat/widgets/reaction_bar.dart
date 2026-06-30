import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:m3t_organizer/features/chat/widgets/emoji_picker_sheet.dart';
import 'package:m3t_organizer/features/chat/widgets/quick_reaction_emojis.dart';

/// Horizontal pill of quick emojis plus a more-emojis button.
final class ReactionBar extends StatelessWidget {
  const ReactionBar({
    required this.reactions,
    required this.onEmojiSelected,
    super.key,
  });

  final List<ChatReaction>? reactions;
  final ValueChanged<String> onEmojiSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final myEmoji = reactions
        ?.where((r) => r.reactedByMe)
        .map((r) => r.emoji)
        .firstOrNull;

    return Material(
      elevation: 8,
      shadowColor: Colors.black45,
      borderRadius: BorderRadius.circular(28),
      color: theme.colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final emoji in kQuickReactionEmojis)
              _ReactionEmojiButton(
                emoji: emoji,
                selected: myEmoji == emoji,
                onTap: () => onEmojiSelected(emoji),
              ),
            _MoreEmojisButton(
              onTap: () async {
                final picked = await showEmojiPickerSheet(context);
                if (picked != null) {
                  onEmojiSelected(picked);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

final class _ReactionEmojiButton extends StatelessWidget {
  const _ReactionEmojiButton({
    required this.emoji,
    required this.selected,
    required this.onTap,
  });

  final String emoji;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: selected
            ? BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              )
            : null,
        child: Text(emoji, style: const TextStyle(fontSize: 26)),
      ),
    );
  }
}

final class _MoreEmojisButton extends StatelessWidget {
  const _MoreEmojisButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Icon(
          Icons.add,
          size: 22,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
