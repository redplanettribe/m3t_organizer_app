/// Domain failures for events operations.
sealed class EventsFailure implements Exception {}

final class EventsNetworkError extends EventsFailure {}

final class EventsUnauthorized extends EventsFailure {}

final class EventsForbidden extends EventsFailure {}

final class EventsNotFound extends EventsFailure {}

final class EventsInvalidInput extends EventsFailure {}

/// Thrown when the backend rejects an update due to a conflicting state
/// (e.g. room already has a Live session).
final class EventsConflict extends EventsFailure {}

final class EventsUnknownError extends EventsFailure {}

//
