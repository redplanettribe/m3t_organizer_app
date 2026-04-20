import 'package:domain/domain.dart';
import 'package:m3t_organizer/core/events/events_failure_message.dart';

/// Event-check-in scanner copy. Sealed switch ensures every backend code we
/// map to an [EventsFailure] is handled with phrasing tuned for an organizer
/// scanning attendee QR codes at the door.
extension EventCheckInFailureMessage on EventsFailure {
  String toEventCheckInMessage() => switch (this) {
    EventsNotFound() =>
      'Could not find this event or attendee. Check the QR code.',
    EventsForbidden() => 'You are not a manager of this event.',
    EventsInvalidInput() => 'This QR code is not valid for check-in.',
    EventsUnprocessableEntity() =>
      'This attendee cannot be checked in to the event right now.',
    EventsConflict() ||
    EventsLiveSessionConflict() ||
    EventsSessionFull() ||
    EventsScheduleConflict() ||
    EventsSessionAllAttend() ||
    EventsDeliverableAlreadyGiven() ||
    EventsNotRegisteredForEvent() ||
    EventsUnauthorized() ||
    EventsInvalidOrExpiredToken() ||
    EventsNetworkError() ||
    EventsUnknownError() => toDisplayMessage(),
  };
}
