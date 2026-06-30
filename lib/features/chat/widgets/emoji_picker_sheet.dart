import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';

/// Opens a bottom sheet with a full emoji picker; returns the selected emoji.
Future<String?> showEmojiPickerSheet(BuildContext context) {
  return showModalBottomSheet<String>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (sheetContext) {
      final theme = Theme.of(sheetContext);
      return SizedBox(
        height: MediaQuery.sizeOf(sheetContext).height * 0.45,
        child: EmojiPicker(
          onEmojiSelected: (category, emoji) {
            Navigator.of(sheetContext).pop(emoji.emoji);
          },
          config: Config(
            height: MediaQuery.sizeOf(sheetContext).height * 0.45,
            emojiViewConfig: EmojiViewConfig(
              backgroundColor: theme.colorScheme.surface,
            ),
            categoryViewConfig: CategoryViewConfig(
              backgroundColor: theme.colorScheme.surface,
              indicatorColor: theme.colorScheme.primary,
              iconColorSelected: theme.colorScheme.primary,
            ),
            bottomActionBarConfig: BottomActionBarConfig(
              backgroundColor: theme.colorScheme.surface,
            ),
            searchViewConfig: SearchViewConfig(
              backgroundColor: theme.colorScheme.surface,
            ),
          ),
        ),
      );
    },
  );
}
