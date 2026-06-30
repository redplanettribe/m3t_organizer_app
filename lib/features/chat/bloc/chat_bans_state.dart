part of 'chat_bans_cubit.dart';

enum ChatBansStatus {
  initial,
  loading,
  ready,
  failure,
}

final class ChatBansState extends Equatable {
  const ChatBansState({
    this.status = ChatBansStatus.initial,
    this.bans = const [],
    this.page,
    this.totalPages,
    this.loadingMore = false,
    this.banningUserId,
    this.errorMessage,
  });

  final ChatBansStatus status;
  final List<ChatBan> bans;
  final int? page;
  final int? totalPages;
  final bool loadingMore;
  final String? banningUserId;
  final String? errorMessage;

  bool get hasMorePages {
    final currentPage = page;
    final pages = totalPages;
    if (currentPage == null || pages == null) return false;
    return currentPage < pages;
  }

  ChatBansState copyWith({
    ChatBansStatus? status,
    List<ChatBan>? bans,
    Object? page = _sentinel,
    Object? totalPages = _sentinel,
    bool? loadingMore,
    Object? banningUserId = _sentinel,
    Object? errorMessage = _sentinel,
  }) {
    return ChatBansState(
      status: status ?? this.status,
      bans: bans ?? this.bans,
      page: page == _sentinel ? this.page : page as int?,
      totalPages: totalPages == _sentinel
          ? this.totalPages
          : totalPages as int?,
      loadingMore: loadingMore ?? this.loadingMore,
      banningUserId: banningUserId == _sentinel
          ? this.banningUserId
          : banningUserId as String?,
      errorMessage: errorMessage == _sentinel
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  static const _sentinel = Object();

  @override
  List<Object?> get props => [
    status,
    bans,
    page,
    totalPages,
    loadingMore,
    banningUserId,
    errorMessage,
  ];
}
