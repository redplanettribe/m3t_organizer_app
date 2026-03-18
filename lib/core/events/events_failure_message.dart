import 'package:domain/domain.dart';

extension EventsFailureMessage on EventsFailure {
  String toDisplayMessage() => switch (this) {
    EventsNetworkError() => 'A network error occurred. Please try again.',
    EventsUnauthorized() => 'Your session expired. Please log in again.',
    EventsUnknownError() => 'An unexpected error occurred. Please try again.',
  };
}

//
