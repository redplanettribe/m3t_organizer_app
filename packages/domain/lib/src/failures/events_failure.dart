/// Domain failures for events operations.
sealed class EventsFailure implements Exception {}

final class EventsNetworkError extends EventsFailure {}

final class EventsUnauthorized extends EventsFailure {}

final class EventsUnknownError extends EventsFailure {}

//
