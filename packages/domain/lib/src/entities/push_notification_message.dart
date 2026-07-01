import 'package:equatable/equatable.dart';

/// Parsed FCM data payload from the backend.
sealed class PushNotificationMessage extends Equatable {
  const PushNotificationMessage();

  /// Client dedupe key (`message_id` or `announcement_id`).
  String get dedupeKey => switch (this) {
    DirectMessagePush(:final messageId) => messageId,
    GeneralChatReplyPush(:final messageId) => messageId,
    OrganizerChatMessagePush(:final messageId) => messageId,
    EventAnnouncementPush(:final announcementId) => announcementId,
  };
}

/// `data.type == direct_message`
final class DirectMessagePush extends PushNotificationMessage {
  const DirectMessagePush({
    required this.eventId,
    required this.messageId,
    required this.conversationId,
    required this.senderName,
    required this.senderUserId,
  });

  final String eventId;
  final String messageId;
  final String conversationId;
  final String senderName;
  final String senderUserId;

  @override
  List<Object?> get props => [
    eventId,
    messageId,
    conversationId,
    senderName,
    senderUserId,
  ];
}

/// `data.type == general_chat_reply`
final class GeneralChatReplyPush extends PushNotificationMessage {
  const GeneralChatReplyPush({
    required this.eventId,
    required this.messageId,
    required this.replyToMessageId,
    required this.senderName,
    required this.senderUserId,
  });

  final String eventId;
  final String messageId;
  final String replyToMessageId;
  final String senderName;
  final String senderUserId;

  @override
  List<Object?> get props => [
    eventId,
    messageId,
    replyToMessageId,
    senderName,
    senderUserId,
  ];
}

/// `data.type == organizer_chat_message`
final class OrganizerChatMessagePush extends PushNotificationMessage {
  const OrganizerChatMessagePush({
    required this.eventId,
    required this.messageId,
    required this.senderName,
    required this.senderUserId,
    this.replyToMessageId,
  });

  final String eventId;
  final String messageId;
  final String senderName;
  final String senderUserId;
  final String? replyToMessageId;

  @override
  List<Object?> get props => [
    eventId,
    messageId,
    senderName,
    senderUserId,
    replyToMessageId,
  ];
}

/// `data.type == event_announcement`
final class EventAnnouncementPush extends PushNotificationMessage {
  const EventAnnouncementPush({
    required this.eventId,
    required this.announcementId,
    required this.action,
    this.sessionId,
    this.url,
  });

  final String eventId;
  final String announcementId;
  final String action;
  final String? sessionId;
  final String? url;

  @override
  List<Object?> get props => [
    eventId,
    announcementId,
    action,
    sessionId,
    url,
  ];
}
