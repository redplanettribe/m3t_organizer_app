import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:m3t_organizer/infrastructure/push_notification_message_parser.dart';

void main() {
  group('parsePushNotificationMessage', () {
    test('parses direct_message payload', () {
      final message = parsePushNotificationMessage({
        'type': 'direct_message',
        'event_id': 'event-1',
        'message_id': 'msg-1',
        'conversation_id': 'dm:event-1:user-a:user-b',
        'sender_name': 'Alice',
        'sender_user_id': 'user-1',
      });

      expect(
        message,
        const DirectMessagePush(
          eventId: 'event-1',
          messageId: 'msg-1',
          conversationId: 'dm:event-1:user-a:user-b',
          senderName: 'Alice',
          senderUserId: 'user-1',
        ),
      );
    });

    test('parses general_chat_reply payload', () {
      final message = parsePushNotificationMessage({
        'type': 'general_chat_reply',
        'event_id': 'event-1',
        'message_id': 'msg-1',
        'reply_to_message_id': 'parent-1',
        'sender_name': 'Alice',
        'sender_user_id': 'user-1',
      });

      expect(
        message,
        const GeneralChatReplyPush(
          eventId: 'event-1',
          messageId: 'msg-1',
          replyToMessageId: 'parent-1',
          senderName: 'Alice',
          senderUserId: 'user-1',
        ),
      );
    });

    test('parses event_announcement payload', () {
      final message = parsePushNotificationMessage({
        'type': 'event_announcement',
        'event_id': 'event-1',
        'announcement_id': 'ann-1',
        'action': 'open_session',
        'session_id': 'session-1',
      });

      expect(
        message,
        const EventAnnouncementPush(
          eventId: 'event-1',
          announcementId: 'ann-1',
          action: 'open_session',
          sessionId: 'session-1',
        ),
      );
    });

    test('parses organizer_chat_message payload with reply', () {
      final message = parsePushNotificationMessage({
        'type': 'organizer_chat_message',
        'event_id': 'event-1',
        'message_id': 'msg-1',
        'sender_name': 'Alice',
        'sender_user_id': 'user-1',
        'reply_to_message_id': 'parent-1',
      });

      expect(
        message,
        const OrganizerChatMessagePush(
          eventId: 'event-1',
          messageId: 'msg-1',
          senderName: 'Alice',
          senderUserId: 'user-1',
          replyToMessageId: 'parent-1',
        ),
      );
    });

    test('parses organizer_chat_message payload without reply', () {
      final message = parsePushNotificationMessage({
        'type': 'organizer_chat_message',
        'event_id': 'event-1',
        'message_id': 'msg-1',
        'sender_name': 'Alice',
        'sender_user_id': 'user-1',
      });

      expect(
        message,
        const OrganizerChatMessagePush(
          eventId: 'event-1',
          messageId: 'msg-1',
          senderName: 'Alice',
          senderUserId: 'user-1',
        ),
      );
    });

    test('returns null for invalid organizer_chat_message payload', () {
      expect(
        parsePushNotificationMessage({
          'type': 'organizer_chat_message',
          'event_id': 'event-1',
        }),
        isNull,
      );
    });

    test('returns null for unknown type', () {
      expect(
        parsePushNotificationMessage({'type': 'unknown'}),
        isNull,
      );
    });
  });
}
