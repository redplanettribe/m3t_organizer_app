import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:m3t_organizer/features/chat/widgets/chat_message_bubble_content.dart';
import 'package:m3t_organizer/features/chat/widgets/chat_message_reactions.dart';
import 'package:m3t_organizer/features/chat/widgets/message_actions_overlay.dart';

/// WhatsApp-style chat message bubble with long-press actions and reactions.
final class ChatMessageBubble extends StatefulWidget {
  const ChatMessageBubble({
    required this.message,
    required this.isOwn,
    required this.onReact,
    required this.onReply,
    this.showSenderName = true,
    this.onDelete,
    super.key,
  });

  final ChatMessage message;
  final bool isOwn;
  final bool showSenderName;
  final void Function(String emoji) onReact;
  final VoidCallback onReply;
  final VoidCallback? onDelete;

  @override
  State<ChatMessageBubble> createState() => _ChatMessageBubbleState();
}

final class _ChatMessageBubbleState extends State<ChatMessageBubble> {
  final GlobalKey _bubbleKey = GlobalKey();

  Future<void> _onLongPress() async {
    final renderBox =
        _bubbleKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return;

    final rect = renderBox.localToGlobal(Offset.zero) & renderBox.size;
    final action = await showMessageActions(
      context: context,
      messageRect: rect,
      message: widget.message,
      isOwn: widget.isOwn,
      showSenderName: widget.showSenderName,
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

    return Align(
      alignment: widget.isOwn ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.only(
          top: 4,
          bottom: hasReactions ? 14 : 4,
        ),
        child: GestureDetector(
          onLongPress: _onLongPress,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                key: _bubbleKey,
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.sizeOf(context).width * 0.78,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: widget.isOwn
                      ? theme.colorScheme.primaryContainer
                      : theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ChatMessageBubbleContent(
                  message: widget.message,
                  isOwn: widget.isOwn,
                  showSenderName: widget.showSenderName,
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
        ),
      ),
    );
  }
}

/// Builds a bubble replica for the long-press overlay.
Widget buildBubbleReplica({
  required BuildContext context,
  required ChatMessage message,
  required bool isOwn,
  required bool showSenderName,
  required double maxWidth,
}) {
  final theme = Theme.of(context);
  return Container(
    constraints: BoxConstraints(maxWidth: maxWidth),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: isOwn
          ? theme.colorScheme.primaryContainer
          : theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12),
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
      showSenderName: showSenderName,
    ),
  );
}
