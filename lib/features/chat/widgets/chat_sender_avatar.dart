import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:m3t_organizer/core/media/media_url_resolver.dart';

/// Circular avatar for a chat message sender (photo or initials).
final class ChatSenderAvatar extends StatelessWidget {
  const ChatSenderAvatar({
    required this.message,
    this.radius = 16,
    this.onTap,
    super.key,
  });

  final ChatMessage message;
  final double radius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final resolvedUrl = MediaUrlResolver.resolveAppUrl(
      message.senderProfilePictureUrl,
    );
    final diameter = radius * 2;
    final initials = _initialsFromMessage(message);
    final style = theme.textTheme.labelSmall?.copyWith(
      color: theme.colorScheme.onPrimaryContainer,
      fontWeight: FontWeight.w600,
    );

    final avatar = resolvedUrl != null && resolvedUrl.isNotEmpty
        ? CircleAvatar(
            radius: radius,
            backgroundColor: theme.colorScheme.primaryContainer,
            child: ClipOval(
              child: Image.network(
                resolvedUrl,
                width: diameter,
                height: diameter,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) =>
                    Center(child: Text(initials, style: style)),
              ),
            ),
          )
        : CircleAvatar(
            radius: radius,
            backgroundColor: theme.colorScheme.primaryContainer,
            child: Text(initials, style: style),
          );

    if (onTap == null) {
      return avatar;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: avatar,
      ),
    );
  }
}

String _initialsFromMessage(ChatMessage message) {
  final name = message.senderName?.trim();
  final lastName = message.senderLastName?.trim();
  if (name != null &&
      name.isNotEmpty &&
      lastName != null &&
      lastName.isNotEmpty) {
    return '${name[0]}${lastName[0]}'.toUpperCase();
  }
  if (name != null && name.isNotEmpty) {
    return name.length >= 2
        ? name.substring(0, 2).toUpperCase()
        : name[0].toUpperCase();
  }
  return '?';
}
