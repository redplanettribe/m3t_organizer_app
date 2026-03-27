/// Thrown when a login-code request fails.
final class RequestLoginCodeFailure implements Exception {
  RequestLoginCodeFailure(this.message);

  final String message;

  @override
  String toString() => 'RequestLoginCodeFailure($message)';
}

/// Thrown when a login-code verification request fails.
final class VerifyLoginCodeFailure implements Exception {
  VerifyLoginCodeFailure(this.message);

  final String message;

  @override
  String toString() => 'VerifyLoginCodeFailure($message)';
}

/// Thrown when fetching the current user's profile fails.
final class GetCurrentUserFailure implements Exception {
  GetCurrentUserFailure(this.message);

  final String message;

  @override
  String toString() => 'GetCurrentUserFailure($message)';
}

/// Thrown when updating the current user's profile fails.
final class UpdateCurrentUserFailure implements Exception {
  UpdateCurrentUserFailure(this.message);

  final String message;

  @override
  String toString() => 'UpdateCurrentUserFailure($message)';
}

/// Thrown when deleting the current user's account fails.
final class DeleteCurrentUserFailure implements Exception {
  DeleteCurrentUserFailure(
    this.message, {
    this.statusCode,
    this.errorCode,
  });

  final String message;
  final int? statusCode;
  final String? errorCode;

  @override
  String toString() =>
      'DeleteCurrentUserFailure(message: $message, statusCode: $statusCode, '
      'errorCode: $errorCode)';
}

/// Thrown when requesting a presigned avatar upload URL fails.
final class RequestAvatarUploadFailure implements Exception {
  RequestAvatarUploadFailure(this.message);

  final String message;

  @override
  String toString() => 'RequestAvatarUploadFailure($message)';
}

/// Thrown when uploading avatar bytes directly to the storage provider fails.
final class UploadAvatarFailure implements Exception {
  UploadAvatarFailure(this.message);

  final String message;

  @override
  String toString() => 'UploadAvatarFailure($message)';
}

/// Thrown when confirming the uploaded avatar with the backend fails.
final class ConfirmAvatarFailure implements Exception {
  ConfirmAvatarFailure(this.message);

  final String message;

  @override
  String toString() => 'ConfirmAvatarFailure($message)';
}

/// Thrown when fetching the events managed by the current user fails.
final class GetMyEventsFailure implements Exception {
  GetMyEventsFailure(this.message);

  final String message;

  @override
  String toString() => 'GetMyEventsFailure($message)';
}

/// Thrown when checking in an attendee to an event fails.
final class CheckInAttendeeFailure implements Exception {
  CheckInAttendeeFailure(
    this.message, {
    this.statusCode,
    this.errorCode,
  });

  final String message;
  final int? statusCode;
  final String? errorCode;

  @override
  String toString() =>
      'CheckInAttendeeFailure(message: $message, statusCode: $statusCode, '
      'errorCode: $errorCode)';
}

/// Thrown when checking in an attendee to a specific session fails.
final class CheckInAttendeeToSessionFailure implements Exception {
  CheckInAttendeeToSessionFailure(
    this.message, {
    this.statusCode,
    this.errorCode,
  });

  final String message;
  final int? statusCode;
  final String? errorCode;

  @override
  String toString() =>
      'CheckInAttendeeToSessionFailure(message: $message, '
      'statusCode: $statusCode, errorCode: $errorCode)';
}

/// Thrown when fetching a single event (with nested rooms/sessions) fails.
final class GetEventByIdFailure implements Exception {
  GetEventByIdFailure(
    this.message, {
    this.statusCode,
    this.errorCode,
  });

  final String message;
  final int? statusCode;
  final String? errorCode;

  @override
  String toString() =>
      'GetEventByIdFailure(message: $message, statusCode: $statusCode, '
      'errorCode: $errorCode)';
}

/// Thrown when fetching session details fails.
final class GetSessionByIdFailure implements Exception {
  GetSessionByIdFailure(
    this.message, {
    this.statusCode,
    this.errorCode,
  });

  final String message;
  final int? statusCode;
  final String? errorCode;

  @override
  String toString() =>
      'GetSessionByIdFailure(message: $message, statusCode: $statusCode, '
      'errorCode: $errorCode)';
}

/// Thrown when updating a session's lifecycle status fails.
final class UpdateSessionStatusFailure implements Exception {
  UpdateSessionStatusFailure(
    this.message, {
    this.statusCode,
    this.errorCode,
  });

  final String message;
  final int? statusCode;
  final String? errorCode;

  @override
  String toString() =>
      'UpdateSessionStatusFailure(message: $message, statusCode: $statusCode, '
      'errorCode: $errorCode)';
}

/// Thrown when listing event deliverables fails.
final class GetEventDeliverablesFailure implements Exception {
  GetEventDeliverablesFailure(
    this.message, {
    this.statusCode,
    this.errorCode,
  });

  final String message;
  final int? statusCode;
  final String? errorCode;

  @override
  String toString() =>
      'GetEventDeliverablesFailure(message: $message, statusCode: $statusCode, '
      'errorCode: $errorCode)';
}

/// Thrown when recording a deliverable giveaway fails.
final class GiveDeliverableFailure implements Exception {
  GiveDeliverableFailure(
    this.message, {
    this.statusCode,
    this.errorCode,
  });

  final String message;
  final int? statusCode;
  final String? errorCode;

  @override
  String toString() =>
      'GiveDeliverableFailure(message: $message, statusCode: $statusCode, '
      'errorCode: $errorCode)';
}

/// Thrown when releasing unchecked-in session bookings fails.
final class ReleaseSessionBookingsFailure implements Exception {
  ReleaseSessionBookingsFailure(
    this.message, {
    this.statusCode,
    this.errorCode,
  });

  final String message;
  final int? statusCode;
  final String? errorCode;

  @override
  String toString() =>
      'ReleaseSessionBookingsFailure(message: $message, '
      'statusCode: $statusCode, errorCode: $errorCode)';
}
