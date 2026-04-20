import 'package:domain/domain.dart';

extension EventsFailureMessage on EventsFailure {
  String toDisplayMessage() => switch (this) {
    EventsNetworkError() => 'A network error occurred. Please try again.',
    EventsUnauthorized() => 'Your session expired. Please log in again.',
    EventsInvalidOrExpiredToken() =>
      'Your session expired. Please log in again.',
    EventsForbidden() => 'You do not have permission to perform this action.',
    EventsConflict() =>
      'This session cannot be activated because the room already '
      'has a live session.',
    EventsLiveSessionConflict() =>
      'This session cannot be activated because the room already '
      'has a live session.',
    EventsDeliverableAlreadyGiven() =>
      'This item was already marked as delivered for this attendee.',
    EventsUnprocessableEntity() =>
      'This action cannot be completed for this attendee right now.',
    EventsNotFound() =>
      'We could not find this event or attendee. Please check the QR code.',
    EventsInvalidInput() =>
      'This QR code is not valid for check-in. Please try another one.',
    EventsSessionFull() =>
      'This session is already full. The attendee cannot be checked in.',
    EventsScheduleConflict() =>
      'The attendee is already checked in to another overlapping session.',
    EventsNotRegisteredForEvent() =>
      'This attendee is not registered for this event.',
    EventsSessionAllAttend() =>
      'The attendee has already checked in to every available session '
      'in their ticket tier.',
    EventsUnknownError() => 'An unexpected error occurred. Please try again.',
  };
}
