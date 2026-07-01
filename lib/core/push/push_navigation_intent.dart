import 'package:domain/domain.dart';
import 'package:equatable/equatable.dart';

/// Deep-link target produced from a push notification tap.
sealed class PushNavigationIntent extends Equatable {
  const PushNavigationIntent();

  factory PushNavigationIntent.fromMessage(PushNotificationMessage message) {
    return switch (message) {
      DirectMessagePush(
        :final eventId,
        :final senderUserId,
        :final senderName,
      ) =>
        OpenEventDmIntent(
          eventId: eventId,
          recipientUserId: senderUserId,
          recipientDisplayName: senderName,
        ),
      GeneralChatReplyPush(:final eventId) => OpenEventChatGeneralIntent(
        eventId: eventId,
      ),
      OrganizerChatMessagePush(
        :final eventId,
        :final messageId,
        :final replyToMessageId,
      ) =>
        OpenEventChatOrganizersIntent(
          eventId: eventId,
          messageId: messageId,
          replyToMessageId: replyToMessageId,
        ),
      EventAnnouncementPush(
        :final eventId,
        :final action,
        :final sessionId,
        :final url,
      ) =>
        switch (action) {
          'open_session' => OpenEventSessionsIntent(
            eventId: eventId,
            sessionId: sessionId,
          ),
          'open_agenda' => OpenEventSessionsIntent(eventId: eventId),
          'open_event' => OpenEventIntent(eventId: eventId),
          'open_url' when url != null && url.isNotEmpty => OpenUrlIntent(
            url: url,
          ),
          _ => OpenEventIntent(eventId: eventId),
        },
    };
  }
}

final class OpenEventIntent extends PushNavigationIntent {
  const OpenEventIntent({required this.eventId});

  final String eventId;

  @override
  List<Object?> get props => [eventId];
}

final class OpenEventChatGeneralIntent extends PushNavigationIntent {
  const OpenEventChatGeneralIntent({required this.eventId});

  final String eventId;

  @override
  List<Object?> get props => [eventId];
}

final class OpenEventChatOrganizersIntent extends PushNavigationIntent {
  const OpenEventChatOrganizersIntent({
    required this.eventId,
    required this.messageId,
    this.replyToMessageId,
  });

  final String eventId;
  final String messageId;
  final String? replyToMessageId;

  @override
  List<Object?> get props => [eventId, messageId, replyToMessageId];
}

final class OpenEventDmIntent extends PushNavigationIntent {
  const OpenEventDmIntent({
    required this.eventId,
    required this.recipientUserId,
    this.recipientDisplayName,
  });

  final String eventId;
  final String recipientUserId;
  final String? recipientDisplayName;

  @override
  List<Object?> get props => [
    eventId,
    recipientUserId,
    recipientDisplayName,
  ];
}

final class OpenEventSessionsIntent extends PushNavigationIntent {
  const OpenEventSessionsIntent({
    required this.eventId,
    this.sessionId,
  });

  final String eventId;
  final String? sessionId;

  @override
  List<Object?> get props => [eventId, sessionId];
}

final class OpenUrlIntent extends PushNavigationIntent {
  const OpenUrlIntent({required this.url});

  final String url;

  @override
  List<Object?> get props => [url];
}

/// Optional GoRoute extra when navigating to an event.
final class EventRouteExtra {
  const EventRouteExtra({
    this.event,
    this.pushIntent,
  });

  final Event? event;
  final PushNavigationIntent? pushIntent;
}
