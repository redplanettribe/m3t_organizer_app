import 'package:domain/domain.dart';
import 'package:m3t_organizer/core/events/events_failure_message.dart';

/// Giveaway API errors (400–500) phrased for loading the list vs scanning.
extension DeliverableGiveawayFailureMessage on EventsFailure {
  String toDeliverableGiveawayLoadMessage() => switch (this) {
    EventsNotFound() =>
      'We could not load deliverables. This event or list may no longer '
      'be available.',
    EventsInvalidInput() =>
      'We could not load the deliverable list. Please try again.',
    _ => toDisplayMessage(),
  };

  String toDeliverableGiveawayScanMessage() => switch (this) {
    EventsInvalidInput() =>
      'We could not record this giveaway. Check the QR code and try again.',
    // Backend codes `deliverable_not_found`, `event_not_found`, and
    // `session_not_found` all collapse into [EventsNotFound].
    EventsNotFound() =>
      'We could not find this deliverable, event, or attendee. '
      'Check the QR code.',
    EventsUnprocessableEntity() =>
      'This attendee must be registered and checked in to the event '
      'before they can receive this item.',
    EventsNotRegisteredForEvent() =>
      'This attendee is not registered for this event.',
    // Backend code `not_event_team_member` collapses into [EventsForbidden].
    EventsForbidden() => "You are not on this event's team.",
    EventsUnauthorized() => toDisplayMessage(),
    EventsInvalidOrExpiredToken() => toDisplayMessage(),
    EventsDeliverableAlreadyGiven() => toDisplayMessage(),
    EventsConflict() => toDisplayMessage(),
    EventsLiveSessionConflict() => toDisplayMessage(),
    EventsSessionFull() => toDisplayMessage(),
    EventsScheduleConflict() => toDisplayMessage(),
    EventsSessionAllAttend() => toDisplayMessage(),
    EventsNetworkError() => toDisplayMessage(),
    EventsUnknownError() => toDisplayMessage(),
  };
}
