/// Domain failures for chat operations.
sealed class ChatFailure implements Exception {}

final class ChatNetworkError extends ChatFailure {}

final class ChatUnauthorized extends ChatFailure {}

final class ChatInvalidOrExpiredToken extends ChatFailure {}

final class ChatForbidden extends ChatFailure {}

final class ChatNotFound extends ChatFailure {}

final class ChatInvalidInput extends ChatFailure {}

final class ChatConflict extends ChatFailure {}

final class ChatUnprocessableEntity extends ChatFailure {}

final class ChatNotRegisteredForEvent extends ChatFailure {}

final class ChatBanned extends ChatFailure {}

final class ChatUnknownError extends ChatFailure {}
