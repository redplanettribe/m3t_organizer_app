import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:m3t_organizer/core/push/push_navigation_intent.dart';

void main() {
  group('PushNavigationIntent.fromMessage', () {
    test('maps direct_message to DM intent', () {
      const message = DirectMessagePush(
        eventId: 'event-1',
        messageId: 'msg-1',
        conversationId: 'dm:event-1:a:b',
        senderName: 'Ada',
        senderUserId: 'user-2',
      );

      expect(
        PushNavigationIntent.fromMessage(message),
        const OpenEventDmIntent(
          eventId: 'event-1',
          recipientUserId: 'user-2',
          recipientDisplayName: 'Ada',
        ),
      );
    });

    test('maps organizer_chat_message to organizers chat intent', () {
      const message = OrganizerChatMessagePush(
        eventId: 'event-1',
        messageId: 'msg-1',
        senderName: 'Ada',
        senderUserId: 'user-2',
        replyToMessageId: 'parent-1',
      );

      expect(
        PushNavigationIntent.fromMessage(message),
        const OpenEventChatOrganizersIntent(
          eventId: 'event-1',
          messageId: 'msg-1',
          replyToMessageId: 'parent-1',
        ),
      );
    });

    test('maps event_announcement open_url', () {
      const message = EventAnnouncementPush(
        eventId: 'event-1',
        announcementId: 'ann-1',
        action: 'open_url',
        url: 'https://example.com',
      );

      expect(
        PushNavigationIntent.fromMessage(message),
        const OpenUrlIntent(url: 'https://example.com'),
      );
    });
  });
}
