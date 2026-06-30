import 'package:domain/domain.dart';

extension ChatFailureMessage on ChatFailure {
  String toDisplayMessage() => switch (this) {
    ChatNetworkError() => 'A network error occurred. Please try again.',
    ChatUnauthorized() => 'Your session expired. Please log in again.',
    ChatInvalidOrExpiredToken() =>
      'Your session expired. Please log in again.',
    ChatForbidden() => 'You do not have permission to access this chat.',
    ChatNotFound() => 'That message could not be found.',
    ChatInvalidInput() => 'Please check your message and try again.',
    ChatConflict() => 'This action could not be completed.',
    ChatUnprocessableEntity() => 'This action could not be completed.',
    ChatNotRegisteredForEvent() =>
      'You must be registered for this event to use chat.',
    ChatBanned() => 'You are banned from sending chat messages.',
    ChatUnknownError() => 'An unexpected error occurred. Please try again.',
  };
}
