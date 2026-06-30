part of 'dm_inbox_cubit.dart';

final class DmInboxState extends Equatable {
  const DmInboxState({
    this.loading = false,
    this.loadingMore = false,
    this.conversations = const [],
    this.nextCursor,
    this.errorMessage,
  });

  final bool loading;
  final bool loadingMore;
  final List<ChatConversation> conversations;
  final String? nextCursor;
  final String? errorMessage;

  DmInboxState copyWith({
    bool? loading,
    bool? loadingMore,
    List<ChatConversation>? conversations,
    Object? nextCursor = _sentinel,
    Object? errorMessage = _sentinel,
  }) {
    return DmInboxState(
      loading: loading ?? this.loading,
      loadingMore: loadingMore ?? this.loadingMore,
      conversations: conversations ?? this.conversations,
      nextCursor: nextCursor == _sentinel
          ? this.nextCursor
          : nextCursor as String?,
      errorMessage: errorMessage == _sentinel
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  static const _sentinel = Object();

  @override
  List<Object?> get props => [
    loading,
    loadingMore,
    conversations,
    nextCursor,
    errorMessage,
  ];
}
