import 'dart:ui';

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
  required double bubbleHeight,
  required ChatMessage message,
  required bool isOwn,
  required bool showSenderHeader,
  required bool canDelete,
  required void Function(String emoji) onReact,
}) {
  return Navigator.of(context).push<MessageAction>(
    PageRouteBuilder(
      opaque: false,
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 180),
      reverseTransitionDuration: const Duration(milliseconds: 140),
      pageBuilder: (context, animation, secondaryAnimation) {
        return _MessageActionsOverlay(
          messageRect: messageRect,
          bubbleHeight: bubbleHeight,
          message: message,
          isOwn: isOwn,
          showSenderHeader: showSenderHeader,
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
    required this.bubbleHeight,
    required this.message,
    required this.isOwn,
    required this.showSenderHeader,
    required this.canDelete,
    required this.onReact,
    required this.animation,
  });

  final Rect messageRect;
  final double bubbleHeight;
  final ChatMessage message;
  final bool isOwn;
  final bool showSenderHeader;
  final bool canDelete;
  final void Function(String emoji) onReact;
  final Animation<double> animation;

  @override
  State<_MessageActionsOverlay> createState() => _MessageActionsOverlayState();
}

final class _MessageActionsOverlayState extends State<_MessageActionsOverlay> {
  static const _reactionBarHeight = 52.0;
  static const _menuRowHeight = 48.0;
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

    final menuItemCount = widget.canDelete ? 3 : 2;
    final menuHeight = _menuRowHeight * menuItemCount;
    final safeTop = padding.top + _reactionBarHeight + _spacing + 8;
    final safeBottom = screenSize.height - padding.bottom - 8;

    var bubbleTop = widget.messageRect.top;
    final bubbleHeight = widget.bubbleHeight;

    double menuAnchorFor(double top) {
      final reactionTop = top - _reactionBarHeight - _spacing;
      final reactionsAbove = reactionTop >= padding.top + 8;
      if (reactionsAbove) {
        return top + bubbleHeight + _spacing;
      }
      return top + bubbleHeight + _spacing + _reactionBarHeight + _spacing;
    }

    var menuAnchorY = menuAnchorFor(bubbleTop);
    if (menuAnchorY + menuHeight > safeBottom) {
      final maxLiftTop = widget.messageRect.top;
      final stackBelowBubble = menuAnchorY - bubbleTop;
      final desiredTop = safeBottom - menuHeight - stackBelowBubble;
      if (safeTop < maxLiftTop) {
        bubbleTop = desiredTop.clamp(safeTop, maxLiftTop);
      } else {
        bubbleTop = maxLiftTop;
      }
      menuAnchorY = menuAnchorFor(bubbleTop);
    }

    final reactionBarTop = bubbleTop - _reactionBarHeight - _spacing;
    final showReactionBarAbove = reactionBarTop >= padding.top + 8;
    final reactionBarY = showReactionBarAbove
        ? reactionBarTop
        : bubbleTop + bubbleHeight + _spacing;
    menuAnchorY = menuAnchorFor(bubbleTop);

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

    final liftOffset = bubbleTop - widget.messageRect.top;
    final liftAnimation = CurvedAnimation(
      parent: widget.animation,
      curve: Curves.easeOutCubic,
    );
    final menuYAtStart = menuAnchorFor(widget.messageRect.top);
    final menuYAtEnd = menuAnchorY;

    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: _pop,
              behavior: HitTestBehavior.opaque,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                child: ColoredBox(
                  color: Colors.black.withValues(alpha: 0.38),
                ),
              ),
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
          AnimatedBuilder(
            animation: liftAnimation,
            builder: (context, child) {
              final top =
                  widget.messageRect.top + liftOffset * liftAnimation.value;
              return Positioned(
                left: widget.messageRect.left,
                top: top,
                width: widget.messageRect.width,
                child: child!,
              );
            },
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
                showSenderHeader: widget.showSenderHeader,
                maxWidth: maxBubbleWidth,
              ),
            ),
          ),
          AnimatedBuilder(
            animation: liftAnimation,
            builder: (context, child) {
              final top =
                  menuYAtStart +
                  (menuYAtEnd - menuYAtStart) * liftAnimation.value;
              return Positioned(
                left: menuLeft,
                top: top,
                width: menuWidth,
                child: child!,
              );
            },
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
