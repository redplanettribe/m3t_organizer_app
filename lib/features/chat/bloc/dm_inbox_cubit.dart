import 'dart:async';

import 'package:domain/domain.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m3t_organizer/core/chat/chat_failure_message.dart';

part 'dm_inbox_state.dart';

/// DM inbox: conversation list, pagination, and inbox WS updates.
final class DmInboxCubit extends Cubit<DmInboxState> {
  DmInboxCubit({
    required ChatRepository chatRepository,
    required String eventID,
    required Stream<ChatRealtimeEvent> realtimeEvents,
    String? currentUserId,
    bool autoInitialize = true,
  }) : _chatRepository = chatRepository,
       _eventID = eventID,
       _currentUserId = currentUserId,
       super(const DmInboxState()) {
    _realtimeSubscription = realtimeEvents.listen(
      _onRealtimeEvent,
      onError: (Object error) => addError(error, StackTrace.current),
    );
    if (autoInitialize) {
      unawaited(loadConversations());
    }
  }

  final ChatRepository _chatRepository;
  final String _eventID;
  final String? _currentUserId;
  static const _pageSize = 50;

  late final StreamSubscription<ChatRealtimeEvent> _realtimeSubscription;

  Future<void> loadConversations({bool silent = false}) async {
    if (!silent) {
      emit(state.copyWith(loading: true, errorMessage: null));
    }
    try {
      final page = await _chatRepository.getDmConversations(
        eventID: _eventID,
        limit: _pageSize,
      );
      emit(
        state.copyWith(
          loading: false,
          conversations: page.items,
          nextCursor: page.nextCursor,
          errorMessage: null,
        ),
      );
    } on ChatFailure catch (failure, stackTrace) {
      addError(failure, stackTrace);
      emit(
        state.copyWith(
          loading: false,
          errorMessage: failure.toDisplayMessage(),
        ),
      );
    } on Object catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(
        state.copyWith(
          loading: false,
          errorMessage: ChatUnknownError().toDisplayMessage(),
        ),
      );
    }
  }

  Future<void> loadMoreConversations() async {
    final cursor = state.nextCursor;
    if (cursor == null || state.loadingMore) return;

    emit(state.copyWith(loadingMore: true, errorMessage: null));
    try {
      final page = await _chatRepository.getDmConversations(
        eventID: _eventID,
        limit: _pageSize,
        cursor: cursor,
      );
      emit(
        state.copyWith(
          loadingMore: false,
          conversations: _mergeConversations(state.conversations, page.items),
          nextCursor: page.nextCursor,
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

  void _onRealtimeEvent(ChatRealtimeEvent event) {
    switch (event) {
      case ChatMessageReceived(:final message):
        if (message.channelType != ChatChannelType.dm) return;
        emit(
          state.copyWith(
            conversations: _upsertConversation(state.conversations, message),
          ),
        );
      case ChatMessageDeleted(
        :final messageId,
        :final channelType,
        :final conversationId,
      ):
        if (channelType != ChatChannelType.dm) return;
        emit(
          state.copyWith(
            conversations: _handleDeletedMessage(
              state.conversations,
              messageId,
              conversationId,
            ),
          ),
        );
      case ChatReactionAdded():
      case ChatReactionRemoved():
        break;
    }
  }

  List<ChatConversation> _upsertConversation(
    List<ChatConversation> conversations,
    ChatMessage message,
  ) {
    final conversationId = message.conversationId;
    if (conversationId == null) return conversations;

    final index = conversations.indexWhere(
      (c) => c.conversationId == conversationId,
    );
    final otherUserId = index >= 0
        ? conversations[index].otherUserId
        : _otherUserIdFromMessage(message);

    final updated = ChatConversation(
      conversationId: conversationId,
      otherUserId: otherUserId,
      lastMessage: message,
    );

    if (index < 0) {
      return [updated, ...conversations];
    }

    final next = List<ChatConversation>.from(conversations)..removeAt(index);
    return [updated, ...next];
  }

  List<ChatConversation> _handleDeletedMessage(
    List<ChatConversation> conversations,
    String messageId,
    String? conversationId,
  ) {
    return conversations
        .map((conversation) {
          if (conversationId != null &&
              conversation.conversationId != conversationId) {
            return conversation;
          }
          final last = conversation.lastMessage;
          if (last?.messageId != messageId) return conversation;
          return ChatConversation(
            conversationId: conversation.conversationId,
            otherUserId: conversation.otherUserId,
          );
        })
        .toList();
  }

  String _otherUserIdFromMessage(ChatMessage message) {
    final selfId = _currentUserId;
    if (selfId != null) {
      if (message.senderUserId == selfId) {
        return message.recipientUserId ?? message.senderUserId;
      }
      return message.senderUserId;
    }
    return message.recipientUserId ?? message.senderUserId;
  }

  @override
  Future<void> close() {
    unawaited(_realtimeSubscription.cancel());
    return super.close();
  }
}

List<ChatConversation> _mergeConversations(
  List<ChatConversation> current,
  List<ChatConversation> more,
) {
  final existingIds = current.map((c) => c.conversationId).toSet();
  final unique = more.where((c) => !existingIds.contains(c.conversationId));
  return [...current, ...unique];
}
