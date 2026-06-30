import 'dart:async';

import 'package:domain/domain.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m3t_organizer/core/chat/chat_failure_message.dart';
import 'package:m3t_organizer/core/events/events_failure_message.dart';

part 'chat_bans_state.dart';

/// Organizer chat ban list, pagination, ban, and unban.
final class ChatBansCubit extends Cubit<ChatBansState> {
  ChatBansCubit({
    required ChatRepository chatRepository,
    required EventsRepository eventsRepository,
    required String eventID,
    bool autoInitialize = true,
  }) : _chatRepository = chatRepository,
       _eventsRepository = eventsRepository,
       _eventID = eventID,
       super(const ChatBansState()) {
    if (autoInitialize) {
      unawaited(loadInitial());
    }
  }

  final ChatRepository _chatRepository;
  final EventsRepository _eventsRepository;
  final String _eventID;

  static const _pageSize = 20;

  Future<void> loadInitial() async {
    emit(
      state.copyWith(
        status: ChatBansStatus.loading,
        errorMessage: null,
      ),
    );
    try {
      final page = await _chatRepository.listChatBans(
        eventID: _eventID,
        page: 1,
        pageSize: _pageSize,
      );
      emit(
        state.copyWith(
          status: ChatBansStatus.ready,
          bans: page.items,
          page: page.page ?? 1,
          totalPages: page.totalPages,
          errorMessage: null,
        ),
      );
    } on ChatFailure catch (failure, stackTrace) {
      addError(failure, stackTrace);
      emit(
        state.copyWith(
          status: ChatBansStatus.failure,
          errorMessage: failure.toDisplayMessage(),
        ),
      );
    } on Object catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(
        state.copyWith(
          status: ChatBansStatus.failure,
          errorMessage: ChatUnknownError().toDisplayMessage(),
        ),
      );
    }
  }

  Future<void> refresh() async {
    emit(state.copyWith(errorMessage: null));
    try {
      final page = await _chatRepository.listChatBans(
        eventID: _eventID,
        page: 1,
        pageSize: _pageSize,
      );
      emit(
        state.copyWith(
          status: ChatBansStatus.ready,
          bans: page.items,
          page: page.page ?? 1,
          totalPages: page.totalPages,
          errorMessage: null,
        ),
      );
    } on ChatFailure catch (failure, stackTrace) {
      addError(failure, stackTrace);
      emit(state.copyWith(errorMessage: failure.toDisplayMessage()));
    } on Object catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(
        state.copyWith(
          errorMessage: ChatUnknownError().toDisplayMessage(),
        ),
      );
    }
  }

  Future<void> loadMore() async {
    final currentPage = state.page;
    final totalPages = state.totalPages;
    if (currentPage == null ||
        totalPages == null ||
        currentPage >= totalPages ||
        state.loadingMore) {
      return;
    }

    emit(state.copyWith(loadingMore: true, errorMessage: null));
    try {
      final page = await _chatRepository.listChatBans(
        eventID: _eventID,
        page: currentPage + 1,
        pageSize: _pageSize,
      );
      final existingIds = state.bans.map((b) => b.userId).toSet();
      final newItems = page.items.where((b) => !existingIds.contains(b.userId));
      emit(
        state.copyWith(
          loadingMore: false,
          bans: [...state.bans, ...newItems],
          page: page.page ?? currentPage + 1,
          totalPages: page.totalPages ?? totalPages,
        ),
      );
    } on ChatFailure catch (failure, stackTrace) {
      addError(failure, stackTrace);
      emit(
        state.copyWith(
          loadingMore: false,
          errorMessage: failure.toDisplayMessage(),
        ),
      );
    } on Object catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(
        state.copyWith(
          loadingMore: false,
          errorMessage: ChatUnknownError().toDisplayMessage(),
        ),
      );
    }
  }

  Future<void> unbanUser(String userId) async {
    try {
      await _chatRepository.unbanChatUser(
        eventID: _eventID,
        userID: userId,
      );
      emit(
        state.copyWith(
          bans: state.bans.where((b) => b.userId != userId).toList(),
          errorMessage: null,
        ),
      );
    } on ChatFailure catch (failure, stackTrace) {
      addError(failure, stackTrace);
      emit(state.copyWith(errorMessage: failure.toDisplayMessage()));
    } on Object catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(
        state.copyWith(
          errorMessage: ChatUnknownError().toDisplayMessage(),
        ),
      );
    }
  }

  Future<void> banUser(String userId) async {
    emit(state.copyWith(banningUserId: userId, errorMessage: null));
    try {
      final ban = await _chatRepository.banChatUser(
        eventID: _eventID,
        userID: userId,
      );
      final updatedBans = state.bans.any((b) => b.userId == userId)
          ? state.bans
              .map((b) => b.userId == userId ? ban : b)
              .toList()
          : [ban, ...state.bans];
      emit(
        state.copyWith(
          banningUserId: null,
          bans: updatedBans,
        ),
      );
    } on ChatFailure catch (failure, stackTrace) {
      addError(failure, stackTrace);
      emit(
        state.copyWith(
          banningUserId: null,
          errorMessage: failure.toDisplayMessage(),
        ),
      );
    } on Object catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(
        state.copyWith(
          banningUserId: null,
          errorMessage: ChatUnknownError().toDisplayMessage(),
        ),
      );
    }
  }

  Future<List<EventRegistration>> searchAttendees(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return const [];
    }

    try {
      final page = await _eventsRepository.listEventRegistrations(
        eventID: _eventID,
        search: trimmed,
        page: 1,
        pageSize: 20,
      );
      return page.items;
    } on EventsFailure catch (failure, stackTrace) {
      addError(failure, stackTrace);
      emit(state.copyWith(errorMessage: failure.toDisplayMessage()));
      return const [];
    } on Object catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(
        state.copyWith(
          errorMessage: ChatUnknownError().toDisplayMessage(),
        ),
      );
      return const [];
    }
  }
}
