part of 'general_chat_cubit.dart';

enum GeneralChatStatus {
  initial,
  loading,
  ready,
  failure,
}

final class GeneralChatState extends Equatable {
  const GeneralChatState({
    this.status = GeneralChatStatus.initial,
    this.messages = const [],
    this.nextCursor,
    this.loadingMore = false,
    this.sending = false,
    this.errorMessage,
    this.currentUserId,
    this.replyingTo,
  });

  final GeneralChatStatus status;
  final List<ChatMessage> messages;
  final String? nextCursor;
  final bool loadingMore;
  final bool sending;
  final String? errorMessage;
  final String? currentUserId;
  final ChatMessage? replyingTo;

  bool get hasMore => nextCursor != null;

  GeneralChatState copyWith({
    GeneralChatStatus? status,
    List<ChatMessage>? messages,
    Object? nextCursor = _sentinel,
    bool? loadingMore,
    bool? sending,
    Object? errorMessage = _sentinel,
    Object? currentUserId = _sentinel,
    Object? replyingTo = _sentinel,
  }) {
    return GeneralChatState(
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
      currentUserId: currentUserId == _sentinel
          ? this.currentUserId
          : currentUserId as String?,
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
    currentUserId,
    replyingTo,
  ];
}
