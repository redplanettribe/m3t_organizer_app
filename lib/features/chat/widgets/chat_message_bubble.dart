import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:m3t_organizer/features/chat/widgets/chat_message_bubble_content.dart';
import 'package:m3t_organizer/features/chat/widgets/chat_message_reactions.dart';
import 'package:m3t_organizer/features/chat/widgets/chat_sender_avatar.dart';
import 'package:m3t_organizer/features/chat/widgets/message_actions_overlay.dart';

const _avatarRadius = 16.0;
const _avatarGap = 8.0;
const double _avatarLeaderWidth = _avatarRadius * 2 + _avatarGap;

/// Tail-corner border radius for chat bubbles (own = right tail, other = left).
BorderRadius chatBubbleBorderRadius({required bool isOwn}) {
  const r = 12.0;
  const tail = 4.0;
  return isOwn
      ? const BorderRadius.only(
          topLeft: Radius.circular(r),
          topRight: Radius.circular(r),
          bottomLeft: Radius.circular(r),
          bottomRight: Radius.circular(tail),
        )
      : const BorderRadius.only(
          topLeft: Radius.circular(tail),
          topRight: Radius.circular(r),
          bottomLeft: Radius.circular(r),
          bottomRight: Radius.circular(r),
        );
}

/// WhatsApp-style chat message bubble with long-press actions and reactions.
final class ChatMessageBubble extends StatefulWidget {
  const ChatMessageBubble({
    required this.message,
    required this.isOwn,
    required this.onReact,
    required this.onReply,
    this.showSenderHeader = true,
    this.onDelete,
    this.onSenderTap,
    super.key,
  });

  final ChatMessage message;
  final bool isOwn;
  final bool showSenderHeader;
  final void Function(String emoji) onReact;
  final VoidCallback onReply;
  final VoidCallback? onDelete;
  final VoidCallback? onSenderTap;

  @override
  State<ChatMessageBubble> createState() => _ChatMessageBubbleState();
}

final class _ChatMessageBubbleState extends State<ChatMessageBubble> {
  final GlobalKey _bubbleKey = GlobalKey();

  Future<void> _onLongPress() async {
    final renderBox =
        _bubbleKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return;

    final bubbleRect = renderBox.localToGlobal(Offset.zero) & renderBox.size;
    final messageRect = widget.isOwn
        ? bubbleRect
        : Rect.fromLTWH(
            bubbleRect.left - _avatarLeaderWidth,
            bubbleRect.top,
            bubbleRect.width + _avatarLeaderWidth,
            bubbleRect.height,
          );
    final action = await showMessageActions(
      context: context,
      messageRect: messageRect,
      bubbleHeight: bubbleRect.height,
      message: widget.message,
      isOwn: widget.isOwn,
      showSenderHeader: widget.showSenderHeader,
      canDelete: widget.onDelete != null,
      onReact: widget.onReact,
    );

    if (!mounted || action == null) return;

    switch (action) {
      case MessageAction.reply:
        widget.onReply();
      case MessageAction.delete:
        widget.onDelete?.call();
      case MessageAction.copy:
        await Clipboard.setData(ClipboardData(text: widget.message.body));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Copied'),
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 1),
            ),
          );
        }
      case MessageAction.react:
        // Reaction handled inside overlay before pop.
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reactions = widget.message.reactions ?? const <ChatReaction>[];
    final hasReactions = reactions.isNotEmpty;
    final maxBubbleWidth = MediaQuery.sizeOf(context).width * 0.78;

    final bubble = IntrinsicWidth(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            constraints: BoxConstraints(maxWidth: maxBubbleWidth),
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: widget.isOwn
                  ? theme.colorScheme.primaryContainer
                  : theme.colorScheme.surfaceContainerHighest,
              borderRadius: chatBubbleBorderRadius(isOwn: widget.isOwn),
            ),
            child: ChatMessageBubbleContent(
              message: widget.message,
              isOwn: widget.isOwn,
              showSenderHeader: widget.showSenderHeader,
              onSenderTap: widget.onSenderTap,
            ),
          ),
          if (hasReactions)
            Positioned(
              bottom: -10,
              right: widget.isOwn ? 8 : null,
              left: widget.isOwn ? null : 8,
              child: ChatMessageReactions(
                reactions: reactions,
                isOwn: widget.isOwn,
                onReactionTap: widget.onReact,
              ),
            ),
        ],
      ),
    );

    return Padding(
      padding: EdgeInsets.only(
        top: 4,
        bottom: hasReactions ? 14 : 4,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: widget.isOwn
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!widget.isOwn) ...[
            if (widget.showSenderHeader)
              ChatSenderAvatar(
                message: widget.message,
                onTap: widget.onSenderTap,
              )
            else
              const SizedBox(width: _avatarLeaderWidth),
            const SizedBox(width: _avatarGap),
          ],
          Flexible(
            child: Align(
              alignment: widget.isOwn
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: GestureDetector(
                onLongPress: _onLongPress,
                child: KeyedSubtree(
                  key: _bubbleKey,
                  child: bubble,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Builds a bubble replica for the long-press overlay (includes avatar row).
Widget buildBubbleReplica({
  required BuildContext context,
  required ChatMessage message,
  required bool isOwn,
  required bool showSenderHeader,
  required double maxWidth,
}) {
  final theme = Theme.of(context);

  final bubble = Container(
    constraints: BoxConstraints(maxWidth: maxWidth),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: isOwn
          ? theme.colorScheme.primaryContainer
          : theme.colorScheme.surfaceContainerHighest,
      borderRadius: chatBubbleBorderRadius(isOwn: isOwn),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.15),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: ChatMessageBubbleContent(
      message: message,
      isOwn: isOwn,
      showSenderHeader: showSenderHeader,
    ),
  );

  if (isOwn) return bubble;

  return Row(
    crossAxisAlignment: CrossAxisAlignment.end,
    mainAxisSize: MainAxisSize.min,
    children: [
      if (showSenderHeader)
        ChatSenderAvatar(message: message)
      else
        const SizedBox(width: _avatarLeaderWidth),
      const SizedBox(width: _avatarGap),
      Flexible(child: bubble),
    ],
  );
}
