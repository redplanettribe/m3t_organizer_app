/// Domain failures for events operations.
sealed class EventsFailure implements Exception {}

final class EventsNetworkError extends EventsFailure {}

final class EventsUnauthorized extends EventsFailure {}

final class EventsForbidden extends EventsFailure {}

final class EventsNotFound extends EventsFailure {}

final class EventsInvalidInput extends EventsFailure {}

/// Thrown when the backend rejects an update due to a conflicting state
/// (e.g. session check-in or session status, or another non-giveaway conflict).
final class EventsConflict extends EventsFailure {}

/// Giveaway API returned 409 conflict: deliverable already given to user.
final class EventsDeliverableAlreadyGiven extends EventsFailure {}

/// HTTP 422 / error.code unprocessable_entity (e.g. recipient ineligible).
final class EventsUnprocessableEntity extends EventsFailure {}

final class EventsUnknownError extends EventsFailure {}

//
