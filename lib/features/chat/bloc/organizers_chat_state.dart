part of 'organizers_chat_cubit.dart';

enum OrganizersChatStatus {
  initial,
  loading,
  ready,
  failure,
}

final class OrganizersChatState extends Equatable {
  const OrganizersChatState({
    this.status = OrganizersChatStatus.initial,
    this.messages = const [],
    this.nextCursor,
    this.loadingMore = false,
    this.sending = false,
    this.errorMessage,
    this.replyingTo,
  });

  final OrganizersChatStatus status;
  final List<ChatMessage> messages;
  final String? nextCursor;
  final bool loadingMore;
  final bool sending;
  final String? errorMessage;
  final ChatMessage? replyingTo;

  OrganizersChatState copyWith({
    OrganizersChatStatus? status,
    List<ChatMessage>? messages,
    Object? nextCursor = _sentinel,
    bool? loadingMore,
    bool? sending,
    Object? errorMessage = _sentinel,
    Object? replyingTo = _sentinel,
  }) {
    return OrganizersChatState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      nextCursor: nextCursor == _sentinel
          ? this.nextCursor
          : nextCursor as String?,
      loadingMore: loadingMore ?? this.loadingMore,
      sending: sending ?? this.sending,
      errorMessage: errorMessage == _sentinel
          ? this.errorMessage
          : errorMessage as String?,
      replyingTo: replyingTo == _sentinel
          ? this.replyingTo
          : replyingTo as ChatMessage?,
    );
  }

  static const _sentinel = Object();

  @override
  List<Object?> get props => [
    status,
    messages,
    nextCursor,
    loadingMore,
    sending,
    errorMessage,
    replyingTo,
  ];
}
