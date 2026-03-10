import 'package:domain/domain.dart';

/// Extension on [GetMyManagedEventsFailure] for user-facing messages.
extension GetMyManagedEventsFailureMessage on GetMyManagedEventsFailure {
  String toDisplayMessage() => switch (this) {
        GetMyManagedEventsNetworkError() =>
          'Connection error. Please try again.',
        GetMyManagedEventsUnauthorized() => 'Please sign in again.',
        GetMyManagedEventsUnknown() =>
          'Something went wrong. Please try again.',
      };
}
