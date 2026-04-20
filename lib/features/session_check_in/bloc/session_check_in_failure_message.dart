import 'package:domain/domain.dart';
import 'package:m3t_organizer/core/events/events_failure_message.dart';

/// Session-check-in scanner copy. Sealed switch ensures every backend code we
/// map to an [EventsFailure] has phrasing tuned for an organizer scanning
/// attendee QR codes at a session door.
extension SessionCheckInFailureMessage on EventsFailure {
  String toSessionCheckInMessage() => switch (this) {
    // Backend `session_not_live` collapses into [EventsConflict] (see
    // `EventsRepositoryImpl._throwEventsFailure`). For the session scanner the
    // attendee can only fail with a 409 if the session is not live, so we
    // phrase it that way here instead of the generic conflict copy.
    EventsConflict() =>
      'This session is not live. Start it before checking in attendees.',
    EventsSessionFull() => 'Session is full. The attendee cannot be added.',
    EventsScheduleConflict() =>
      'Attendee is already checked in to an overlapping session.',
    EventsSessionAllAttend() =>
      'Attendee has already checked in to every session in their ticket tier.',
    EventsForbidden() =>
      "Attendee's ticket tier does not allow this session.",
    EventsNotRegisteredForEvent() =>
      'Attendee is not registered for this event.',
    EventsNotFound() =>
      'Session or attendee not found. Check the QR code.',
    EventsInvalidInput() =>
      'This QR code is not valid for check-in. Try another one.',
    EventsUnprocessableEntity() =>
      'This attendee cannot be checked in to this session right now.',
    EventsLiveSessionConflict() ||
    EventsDeliverableAlreadyGiven() ||
    EventsUnauthorized() ||
    EventsInvalidOrExpiredToken() ||
    EventsNetworkError() ||
    EventsUnknownError() => toDisplayMessage(),
  };
}
