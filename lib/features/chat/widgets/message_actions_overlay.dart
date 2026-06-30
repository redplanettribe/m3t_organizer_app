import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:m3t_organizer/features/chat/widgets/chat_message_bubble.dart';
import 'package:m3t_organizer/features/chat/widgets/reaction_bar.dart';

/// Actions returned from the long-press overlay.
enum MessageAction {
  reply,
  delete,
  copy,
  react,
}

/// Shows a WhatsApp-style overlay: reaction bar, bubble replica, actions.
Future<MessageAction?> showMessageActions({
  required BuildContext context,
  required Rect messageRect,
  required ChatMessage message,
  required bool isOwn,
  required bool showSenderName,
  required bool canDelete,
  required void Function(String emoji) onReact,
}) {
  return Navigator.of(context).push<MessageAction>(
    PageRouteBuilder(
      opaque: false,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 180),
      reverseTransitionDuration: const Duration(milliseconds: 140),
      pageBuilder: (context, animation, secondaryAnimation) {
        return _MessageActionsOverlay(
          messageRect: messageRect,
          message: message,
          isOwn: isOwn,
          showSenderName: showSenderName,
          canDelete: canDelete,
          onReact: onReact,
          animation: animation,
        );
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    ),
  );
}

final class _MessageActionsOverlay extends StatefulWidget {
  const _MessageActionsOverlay({
    required this.messageRect,
    required this.message,
    required this.isOwn,
    required this.showSenderName,
    required this.canDelete,
    required this.onReact,
    required this.animation,
  });

  final Rect messageRect;
  final ChatMessage message;
  final bool isOwn;
  final bool showSenderName;
  final bool canDelete;
  final void Function(String emoji) onReact;
  final Animation<double> animation;

  @override
  State<_MessageActionsOverlay> createState() => _MessageActionsOverlayState();
}

final class _MessageActionsOverlayState extends State<_MessageActionsOverlay> {
  static const _reactionBarHeight = 52.0;
  static const _menuHeight = 48.0;
  static const _spacing = 8.0;

  void _pop([MessageAction? action]) {
    Navigator.of(context).pop(action);
  }

  void _handleReaction(String emoji) {
    widget.onReact(emoji);
    _pop(MessageAction.react);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final padding = MediaQuery.paddingOf(context);
    final maxBubbleWidth = screenSize.width * 0.78;

    final reactionBarTop =
        widget.messageRect.top - _reactionBarHeight - _spacing;
    final showReactionBarAbove = reactionBarTop >= padding.top + 8;
    final reactionBarY = showReactionBarAbove
        ? reactionBarTop
        : widget.messageRect.bottom + _spacing;

    final menuTop = widget.messageRect.bottom + _spacing;
    final showMenuBelow =
        menuTop + _menuHeight * (widget.canDelete ? 3 : 2) <=
        screenSize.height - padding.bottom - 8;
    final menuY = showMenuBelow
        ? menuTop
        : widget.messageRect.top -
              _spacing -
              _menuHeight * (widget.canDelete ? 3 : 2);

    final bubbleCenterX = widget.messageRect.center.dx;
    final reactionBarLeft = (bubbleCenterX - 180).clamp(
      8.0,
      screenSize.width - 360 - 8,
    );

    const menuWidth = 200.0;
    final menuLeft = widget.isOwn
        ? (widget.messageRect.right - menuWidth).clamp(
            8.0,
            screenSize.width - menuWidth - 8,
          )
        : widget.messageRect.left.clamp(
            8.0,
            screenSize.width - menuWidth - 8,
          );

    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: _pop,
              behavior: HitTestBehavior.opaque,
              child: const ColoredBox(color: Colors.transparent),
            ),
          ),
          Positioned(
            left: reactionBarLeft,
            top: reactionBarY,
            child: ScaleTransition(
              scale: CurvedAnimation(
                parent: widget.animation,
                curve: Curves.easeOutBack,
              ),
              child: ReactionBar(
                reactions: widget.message.reactions,
                onEmojiSelected: _handleReaction,
              ),
            ),
          ),
          Positioned(
            left: widget.messageRect.left,
            top: widget.messageRect.top,
            width: widget.messageRect.width,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.95, end: 1).animate(
                CurvedAnimation(
                  parent: widget.animation,
                  curve: Curves.easeOut,
                ),
              ),
              child: buildBubbleReplica(
                context: context,
                message: widget.message,
                isOwn: widget.isOwn,
                showSenderName: widget.showSenderName,
                maxWidth: maxBubbleWidth,
              ),
            ),
          ),
          Positioned(
            left: menuLeft,
            top: menuY,
            width: menuWidth,
            child: ScaleTransition(
              scale: CurvedAnimation(
                parent: widget.animation,
                curve: Curves.easeOutBack,
              ),
              child: _ActionsMenu(
                canDelete: widget.canDelete,
                onReply: () => _pop(MessageAction.reply),
                onDelete: () => _pop(MessageAction.delete),
                onCopy: () => _pop(MessageAction.copy),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

final class _ActionsMenu extends StatelessWidget {
  const _ActionsMenu({
    required this.canDelete,
    required this.onReply,
    required this.onDelete,
    required this.onCopy,
  });

  final bool canDelete;
  final VoidCallback onReply;
  final VoidCallback onDelete;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      elevation: 8,
      shadowColor: Colors.black45,
      borderRadius: BorderRadius.circular(12),
      color: theme.colorScheme.surface,
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ActionTile(
            icon: Icons.reply_rounded,
            label: 'Reply',
            onTap: onReply,
          ),
          if (canDelete)
            _ActionTile(
              icon: Icons.delete_outline,
              label: 'Delete',
              onTap: onDelete,
              destructive: true,
            ),
          _ActionTile(
            icon: Icons.copy_rounded,
            label: 'Copy',
            onTap: onCopy,
          ),
        ],
      ),
    );
  }
}

final class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.destructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = destructive
        ? theme.colorScheme.error
        : theme.colorScheme.onSurface;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 12),
            Text(
              label,
              style: theme.textTheme.bodyLarge?.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}
