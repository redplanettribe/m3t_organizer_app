import 'package:domain/domain.dart';

extension EventsFailureMessage on EventsFailure {
  String toDisplayMessage() => switch (this) {
    EventsNetworkError() => 'A network error occurred. Please try again.',
    EventsUnauthorized() => 'Your session expired. Please log in again.',
    EventsForbidden() => 'You do not have permission to perform this action.',
    EventsConflict() =>
      'This session cannot be activated because the room already '
      'has a live session.',
    EventsNotFound() =>
      'We could not find this event or attendee. Please check the QR code.',
    EventsInvalidInput() =>
      'This QR code is not valid for check-in. Please try another one.',
    EventsUnknownError() => 'An unexpected error occurred. Please try again.',
  };
}

//
