/// Domain failures for events operations.
sealed class EventsFailure implements Exception {}

final class EventsNetworkError extends EventsFailure {}

final class EventsUnauthorized extends EventsFailure {}

/// JWT missing, expired, or revoked (backend error code
/// `invalid_or_expired_token`). UI should navigate to login.
final class EventsInvalidOrExpiredToken extends EventsFailure {}

final class EventsForbidden extends EventsFailure {}

final class EventsNotFound extends EventsFailure {}

final class EventsInvalidInput extends EventsFailure {}

/// Thrown when the backend rejects an update due to a conflicting state
/// (e.g. session check-in or session status, or another non-giveaway conflict).
final class EventsConflict extends EventsFailure {}

/// Giveaway API returned 409 conflict: deliverable already given to user.
final class EventsDeliverableAlreadyGiven extends EventsFailure {}

/// HTTP 422 / error.code `unprocessable_entity` (e.g. recipient ineligible).
final class EventsUnprocessableEntity extends EventsFailure {}

/// Session check-in rejected because the session is at capacity
/// (backend error code `session_full`).
final class EventsSessionFull extends EventsFailure {}

/// Session check-in rejected because the attendee is already checked in to
/// another overlapping session (backend error code `schedule_conflict`).
final class EventsScheduleConflict extends EventsFailure {}

/// Session status update rejected because another session in the same room
/// is currently live (backend error code `live_session_conflict`).
final class EventsLiveSessionConflict extends EventsFailure {}

/// User is not registered for the event they are interacting with
/// (backend error code `not_registered_for_event`).
final class EventsNotRegisteredForEvent extends EventsFailure {}

/// Session check-in rejected because the attendee has already checked in to
/// every assignable session in their ticket tier (backend error code
/// `session_all_attend`).
final class EventsSessionAllAttend extends EventsFailure {}

final class EventsUnknownError extends EventsFailure {}
