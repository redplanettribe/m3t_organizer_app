sealed class AuthFailure implements Exception {}

final class InvalidEmail extends AuthFailure {}

final class InvalidCode extends AuthFailure {}

final class NetworkError extends AuthFailure {}

final class UnknownError extends AuthFailure {}

/// Emitted when a profile update is attempted with no valid name fields.
///
/// Both the first name and last name are blank or null. Unlike
/// [NetworkError], this failure is deterministic — retrying without
/// changing the input will always reproduce it.
final class InvalidProfileInput extends AuthFailure {}
