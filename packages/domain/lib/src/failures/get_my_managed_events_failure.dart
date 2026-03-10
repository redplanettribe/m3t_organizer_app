sealed class GetMyManagedEventsFailure implements Exception {}

/// Network or connectivity error when loading managed events.
final class GetMyManagedEventsNetworkError extends GetMyManagedEventsFailure {}

/// Unauthorized (e.g. token expired).
final class GetMyManagedEventsUnauthorized extends GetMyManagedEventsFailure {}

/// Unspecified error.
final class GetMyManagedEventsUnknown extends GetMyManagedEventsFailure {}
