import 'package:domain/domain.dart';

/// Maps backend FCM `data` payloads to domain [PushNotificationMessage].
PushNotificationMessage? parsePushNotificationMessage(
  Map<String, dynamic> data,
) {
  final type = data['type'];
  if (type is! String) {
    return null;
  }

  return switch (type) {
    'direct_message' => _parseDirectMessage(data),
    'general_chat_reply' => _parseGeneralChatReply(data),
    'organizer_chat_message' => _parseOrganizerChatMessage(data),
    'event_announcement' => _parseEventAnnouncement(data),
    _ => null,
  };
}

DirectMessagePush? _parseDirectMessage(Map<String, dynamic> data) {
  final eventId = data['event_id'];
  final messageId = data['message_id'];
  final conversationId = data['conversation_id'];
  final senderName = data['sender_name'];
  final senderUserId = data['sender_user_id'];
  if (eventId is! String ||
      messageId is! String ||
      conversationId is! String ||
      senderName is! String ||
      senderUserId is! String) {
    return null;
  }

  return DirectMessagePush(
    eventId: eventId,
    messageId: messageId,
    conversationId: conversationId,
    senderName: senderName,
    senderUserId: senderUserId,
  );
}

GeneralChatReplyPush? _parseGeneralChatReply(Map<String, dynamic> data) {
  final eventId = data['event_id'];
  final messageId = data['message_id'];
  final replyToMessageId = data['reply_to_message_id'];
  final senderName = data['sender_name'];
  final senderUserId = data['sender_user_id'];
  if (eventId is! String ||
      messageId is! String ||
      replyToMessageId is! String ||
      senderName is! String ||
      senderUserId is! String) {
    return null;
  }

  return GeneralChatReplyPush(
    eventId: eventId,
    messageId: messageId,
    replyToMessageId: replyToMessageId,
    senderName: senderName,
    senderUserId: senderUserId,
  );
}

OrganizerChatMessagePush? _parseOrganizerChatMessage(
  Map<String, dynamic> data,
) {
  final eventId = data['event_id'];
  final messageId = data['message_id'];
  final senderName = data['sender_name'];
  final senderUserId = data['sender_user_id'];
  if (eventId is! String ||
      messageId is! String ||
      senderName is! String ||
      senderUserId is! String) {
    return null;
  }

  final replyToMessageId = data['reply_to_message_id'];

  return OrganizerChatMessagePush(
    eventId: eventId,
    messageId: messageId,
    senderName: senderName,
    senderUserId: senderUserId,
    replyToMessageId: replyToMessageId is String ? replyToMessageId : null,
  );
}

EventAnnouncementPush? _parseEventAnnouncement(Map<String, dynamic> data) {
  final eventId = data['event_id'];
  final announcementId = data['announcement_id'];
  final action = data['action'];
  if (eventId is! String || announcementId is! String || action is! String) {
    return null;
  }

  final sessionId = data['session_id'];
  final url = data['url'];

  return EventAnnouncementPush(
    eventId: eventId,
    announcementId: announcementId,
    action: action,
    sessionId: sessionId is String ? sessionId : null,
    url: url is String ? url : null,
  );
}
