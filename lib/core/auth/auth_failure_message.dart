import 'package:domain/domain.dart';

/// Extension on [AuthFailure] that maps each failure variant to a
/// human-readable display message.
///
/// Lives in the presentation layer intentionally. When l10n is introduced,
/// accept `AppLocalizations` as a parameter and return localised strings
/// from the arb file instead.
extension AuthFailureMessage on AuthFailure {
  String toDisplayMessage() => switch (this) {
    NetworkError() => 'A network error occurred. Please try again.',
    InvalidCode() => 'The verification code is invalid.',
    InvalidEmail() => 'The email address is invalid.',
    // Intentionally no "try again" — retrying with blank fields always fails.
    InvalidProfileInput() => 'Enter at least a first or last name.',
    AccountDeleteConflict() =>
        'You cannot delete your account while you own an active event. '
        'Wait until the event has ended or transfer ownership first.',
    UnknownError() => 'An unexpected error occurred. Please try again.',
  };
}
