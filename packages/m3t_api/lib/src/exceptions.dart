/// Base class for all transport-layer exceptions thrown by the m3t_api client.
///
/// Every failure carries the backend's standard error envelope fields:
/// - [message]: human-readable error message (localized if available).
/// - [statusCode]: HTTP status code of the response, when known.
/// - [errorCode]: machine-readable business code from `error.code`, when
///   present. Repositories switch on this first to map to domain failures.
/// - [showToUser]: backend hint that [message] is safe to render to the user.
///   Stays inside the API layer; repositories do not propagate it to domain.
abstract class M3tApiException implements Exception {
  M3tApiException(
    this.message, {
    this.statusCode,
    this.errorCode,
    this.showToUser = false,
  });

  final String message;
  final int? statusCode;
  final String? errorCode;
  final bool showToUser;

  @override
  String toString() =>
      '$runtimeType(message: $message, statusCode: $statusCode, '
      'errorCode: $errorCode, showToUser: $showToUser)';
}

/// Thrown when a login-code request fails.
final class RequestLoginCodeFailure extends M3tApiException {
  RequestLoginCodeFailure(
    super.message, {
    super.statusCode,
    super.errorCode,
    super.showToUser,
  });
}

/// Thrown when a login-code verification request fails.
final class VerifyLoginCodeFailure extends M3tApiException {
  VerifyLoginCodeFailure(
    super.message, {
    super.statusCode,
    super.errorCode,
    super.showToUser,
  });
}

/// Thrown when fetching the current user's profile fails.
final class GetCurrentUserFailure extends M3tApiException {
  GetCurrentUserFailure(
    super.message, {
    super.statusCode,
    super.errorCode,
    super.showToUser,
  });
}

/// Thrown when updating the current user's profile fails.
final class UpdateCurrentUserFailure extends M3tApiException {
  UpdateCurrentUserFailure(
    super.message, {
    super.statusCode,
    super.errorCode,
    super.showToUser,
  });
}

/// Thrown when deleting the current user's account fails.
final class DeleteCurrentUserFailure extends M3tApiException {
  DeleteCurrentUserFailure(
    super.message, {
    super.statusCode,
    super.errorCode,
    super.showToUser,
  });
}

/// Thrown when requesting a presigned avatar upload URL fails.
final class RequestAvatarUploadFailure extends M3tApiException {
  RequestAvatarUploadFailure(
    super.message, {
    super.statusCode,
    super.errorCode,
    super.showToUser,
  });
}

/// Thrown when uploading avatar bytes directly to the storage provider fails.
final class UploadAvatarFailure extends M3tApiException {
  UploadAvatarFailure(
    super.message, {
    super.statusCode,
    super.errorCode,
    super.showToUser,
  });
}

/// Thrown when confirming the uploaded avatar with the backend fails.
final class ConfirmAvatarFailure extends M3tApiException {
  ConfirmAvatarFailure(
    super.message, {
    super.statusCode,
    super.errorCode,
    super.showToUser,
  });
}

/// Thrown when fetching the events managed by the current user fails.
final class GetMyEventsFailure extends M3tApiException {
  GetMyEventsFailure(
    super.message, {
    super.statusCode,
    super.errorCode,
    super.showToUser,
  });
}

/// Thrown when checking in an attendee to an event fails.
final class CheckInAttendeeFailure extends M3tApiException {
  CheckInAttendeeFailure(
    super.message, {
    super.statusCode,
    super.errorCode,
    super.showToUser,
  });
}

/// Thrown when checking in an attendee to a specific session fails.
final class CheckInAttendeeToSessionFailure extends M3tApiException {
  CheckInAttendeeToSessionFailure(
    super.message, {
    super.statusCode,
    super.errorCode,
    super.showToUser,
  });
}

/// Thrown when fetching a single event (with nested rooms/sessions) fails.
final class GetEventByIdFailure extends M3tApiException {
  GetEventByIdFailure(
    super.message, {
    super.statusCode,
    super.errorCode,
    super.showToUser,
  });
}

/// Thrown when fetching session details fails.
final class GetSessionByIdFailure extends M3tApiException {
  GetSessionByIdFailure(
    super.message, {
    super.statusCode,
    super.errorCode,
    super.showToUser,
  });
}

/// Thrown when updating a session's lifecycle status fails.
final class UpdateSessionStatusFailure extends M3tApiException {
  UpdateSessionStatusFailure(
    super.message, {
    super.statusCode,
    super.errorCode,
    super.showToUser,
  });
}

/// Thrown when listing event deliverables fails.
final class GetEventDeliverablesFailure extends M3tApiException {
  GetEventDeliverablesFailure(
    super.message, {
    super.statusCode,
    super.errorCode,
    super.showToUser,
  });
}

/// Thrown when recording a deliverable giveaway fails.
final class GiveDeliverableFailure extends M3tApiException {
  GiveDeliverableFailure(
    super.message, {
    super.statusCode,
    super.errorCode,
    super.showToUser,
  });
}

/// Thrown when releasing unchecked-in session bookings fails.
final class ReleaseSessionBookingsFailure extends M3tApiException {
  ReleaseSessionBookingsFailure(
    super.message, {
    super.statusCode,
    super.errorCode,
    super.showToUser,
  });
}

/// Thrown when requesting a WebSocket ticket for organizer agenda fails.
final class GetOrganizerAgendaWsTicketFailure extends M3tApiException {
  GetOrganizerAgendaWsTicketFailure(
    super.message, {
    super.statusCode,
    super.errorCode,
    super.showToUser,
  });
}

/// Thrown when fetching the mobile remote config fails.
final class GetMobileRemoteConfigFailure extends M3tApiException {
  GetMobileRemoteConfigFailure(
    super.message, {
    super.statusCode,
    super.errorCode,
    super.showToUser,
  });
}

/// Thrown when fetching DM inbox conversations fails.
final class GetDmConversationsFailure extends M3tApiException {
  GetDmConversationsFailure(
    super.message, {
    super.statusCode,
    super.errorCode,
    super.showToUser,
  });
}

/// Thrown when fetching DM thread history fails.
final class GetDmMessagesFailure extends M3tApiException {
  GetDmMessagesFailure(
    super.message, {
    super.statusCode,
    super.errorCode,
    super.showToUser,
  });
}

/// Thrown when sending a DM fails.
final class SendDmMessageFailure extends M3tApiException {
  SendDmMessageFailure(
    super.message, {
    super.statusCode,
    super.errorCode,
    super.showToUser,
  });
}

/// Thrown when organizer chat history fetch fails.
final class GetOrganizerChatMessagesFailure extends M3tApiException {
  GetOrganizerChatMessagesFailure(
    super.message, {
    super.statusCode,
    super.errorCode,
    super.showToUser,
  });
}

/// Thrown when sending an organizer chat message fails.
final class SendOrganizerChatMessageFailure extends M3tApiException {
  SendOrganizerChatMessageFailure(
    super.message, {
    super.statusCode,
    super.errorCode,
    super.showToUser,
  });
}

/// Thrown when deleting an organizer chat message fails.
final class DeleteOrganizerChatMessageFailure extends M3tApiException {
  DeleteOrganizerChatMessageFailure(
    super.message, {
    super.statusCode,
    super.errorCode,
    super.showToUser,
  });
}

/// Thrown when setting an organizer chat reaction fails.
final class SetOrganizerChatReactionFailure extends M3tApiException {
  SetOrganizerChatReactionFailure(
    super.message, {
    super.statusCode,
    super.errorCode,
    super.showToUser,
  });
}

/// Thrown when removing an organizer chat reaction fails.
final class RemoveOrganizerChatReactionFailure extends M3tApiException {
  RemoveOrganizerChatReactionFailure(
    super.message, {
    super.statusCode,
    super.errorCode,
    super.showToUser,
  });
}

/// Thrown when organizer moderation delete of a general message fails.
final class DeleteGeneralChatMessageFailure extends M3tApiException {
  DeleteGeneralChatMessageFailure(
    super.message, {
    super.statusCode,
    super.errorCode,
    super.showToUser,
  });
}

/// Thrown when banning a user from chat fails.
final class BanChatUserFailure extends M3tApiException {
  BanChatUserFailure(
    super.message, {
    super.statusCode,
    super.errorCode,
    super.showToUser,
  });
}

/// Thrown when unbanning a user from chat fails.
final class UnbanChatUserFailure extends M3tApiException {
  UnbanChatUserFailure(
    super.message, {
    super.statusCode,
    super.errorCode,
    super.showToUser,
  });
}

/// Thrown when listing chat bans fails.
final class ListChatBansFailure extends M3tApiException {
  ListChatBansFailure(
    super.message, {
    super.statusCode,
    super.errorCode,
    super.showToUser,
  });
}

/// Thrown when listing general chat messages fails.
final class GetGeneralChatMessagesFailure extends M3tApiException {
  GetGeneralChatMessagesFailure(
    super.message, {
    super.statusCode,
    super.errorCode,
    super.showToUser,
  });
}

/// Thrown when sending a general chat message fails.
final class SendGeneralChatMessageFailure extends M3tApiException {
  SendGeneralChatMessageFailure(
    super.message, {
    super.statusCode,
    super.errorCode,
    super.showToUser,
  });
}

/// Thrown when deleting an attendee chat message fails.
final class DeleteAttendeeChatMessageFailure extends M3tApiException {
  DeleteAttendeeChatMessageFailure(
    super.message, {
    super.statusCode,
    super.errorCode,
    super.showToUser,
  });
}

/// Thrown when setting a chat message reaction fails.
final class SetChatMessageReactionFailure extends M3tApiException {
  SetChatMessageReactionFailure(
    super.message, {
    super.statusCode,
    super.errorCode,
    super.showToUser,
  });
}

/// Thrown when removing a chat message reaction fails.
final class RemoveChatMessageReactionFailure extends M3tApiException {
  RemoveChatMessageReactionFailure(
    super.message, {
    super.statusCode,
    super.errorCode,
    super.showToUser,
  });
}
