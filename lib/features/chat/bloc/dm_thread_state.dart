part of 'dm_thread_cubit.dart';

final class DmThreadState extends Equatable {
  const DmThreadState({
    required this.recipientDisplayName,
    this.loading = true,
    this.loadingMore = false,
    this.messages = const [],
    this.nextCursor,
    this.sending = false,
    this.errorMessage,
    this.replyingTo,
  });

  final bool loading;
  final bool loadingMore;
  final List<ChatMessage> messages;
  final String? nextCursor;
  final bool sending;
  final String? errorMessage;
  final String recipientDisplayName;
  final ChatMessage? replyingTo;

  DmThreadState copyWith({
    bool? loading,
    bool? loadingMore,
    List<ChatMessage>? messages,
    Object? nextCursor = _sentinel,
    bool? sending,
    Object? errorMessage = _sentinel,
    String? recipientDisplayName,
    Object? replyingTo = _sentinel,
  }) {
    return DmThreadState(
      loading: loading ?? this.loading,
      loadingMore: loadingMore ?? this.loadingMore,
      messages: messages ?? this.messages,
      nextCursor: nextCursor == _sentinel
          ? this.nextCursor
          : nextCursor as String?,
      sending: sending ?? this.sending,
      errorMessage: errorMessage == _sentinel
          ? this.errorMessage
          : errorMessage as String?,
      recipientDisplayName: recipientDisplayName ?? this.recipientDisplayName,
      replyingTo: replyingTo == _sentinel
          ? this.replyingTo
          : replyingTo as ChatMessage?,
    );
  }

  static const _sentinel = Object();

  @override
  List<Object?> get props => [
    loading,
    loadingMore,
    messages,
    nextCursor,
    sending,
    errorMessage,
    recipientDisplayName,
    replyingTo,
  ];
}
