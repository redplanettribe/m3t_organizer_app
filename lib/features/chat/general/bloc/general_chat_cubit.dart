import 'dart:async';

import 'package:domain/domain.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m3t_organizer/core/chat/chat_failure_message.dart';

part 'general_chat_state.dart';

/// Manages general event chat: history, send, reactions, and WS updates.
final class GeneralChatCubit extends Cubit<GeneralChatState> {
  GeneralChatCubit({
    required ChatRepository chatRepository,
    required AuthRepository authRepository,
    required String eventID,
    bool autoInitialize = true,
  }) : _chatRepository = chatRepository,
       _authRepository = authRepository,
       _eventID = eventID,
       super(const GeneralChatState()) {
    if (autoInitialize) {
      unawaited(initialize());
    }
  }

  final ChatRepository _chatRepository;
  final AuthRepository _authRepository;
  final String _eventID;
  ChatRealtimeHandle? _realtimeHandle;

  static const _pageSize = 50;

  Future<void> initialize() async {
    emit(state.copyWith(status: GeneralChatStatus.loading, errorMessage: null));
    try {
      final user = await _authRepository.getCurrentUser();
      _connectGeneralRealtime();
      final page = await _chatRepository.getGeneralMessages(
        eventID: _eventID,
        limit: _pageSize,
      );
      emit(
        state.copyWith(
          status: GeneralChatStatus.ready,
          messages: page.items,
          nextCursor: page.nextCursor,
          currentUserId: user.id,
          errorMessage: null,
        ),
      );
    } on ChatFailure catch (failure, stackTrace) {
      addError(failure, stackTrace);
      emit(
        state.copyWith(
          status: GeneralChatStatus.failure,
          errorMessage: failure.toDisplayMessage(),
        ),
      );
    } on Object catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(
        state.copyWith(
          status: GeneralChatStatus.failure,
          errorMessage: ChatUnknownError().toDisplayMessage(),
        ),
      );
    }
  }

  void _connectGeneralRealtime() {
    final topic = 'attendee.chat.${_eventID.toLowerCase()}.general';
    _realtimeHandle = _chatRepository.connectChatRealtime(
      eventID: _eventID,
      topics: [topic],
      onEvent: _onRealtimeEvent,
      onError: (error) => addError(error, StackTrace.current),
    );
  }

  /// Exposes WS wiring for unit tests without running [initialize].
  @visibleForTesting
  void connectGeneralRealtimeForTest() => _connectGeneralRealtime();

  void _onRealtimeEvent(ChatRealtimeEvent event) {
    switch (event) {
      case ChatMessageReceived(:final message):
        if (message.channelType != ChatChannelType.general) return;
        emit(state.copyWith(messages: _upsertMessage(state.messages, message)));
      case ChatMessageDeleted(:final messageId, :final channelType):
        if (channelType != ChatChannelType.general) return;
        emit(
          state.copyWith(
            messages: _removeMessage(state.messages, messageId),
          ),
        );
      case ChatReactionAdded(:final messageId, :final reactions):
        emit(
          state.copyWith(
            messages: _updateReactions(state.messages, messageId, reactions),
          ),
        );
      case ChatReactionRemoved(:final messageId, :final reactions):
        emit(
          state.copyWith(
            messages: _updateReactions(state.messages, messageId, reactions),
          ),
        );
    }
  }

  Future<void> loadOlderMessages() async {
    final cursor = state.nextCursor;
    if (cursor == null || state.loadingMore) return;

    emit(state.copyWith(loadingMore: true, errorMessage: null));
    try {
      final page = await _chatRepository.getGeneralMessages(
        eventID: _eventID,
        limit: _pageSize,
        cursor: cursor,
      );
      emit(
        state.copyWith(
          loadingMore: false,
          messages: _mergeOlderMessages(state.messages, page.items),
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

  Future<void> sendMessage(String body) async {
    final trimmed = body.trim();
    if (trimmed.isEmpty || state.sending) return;

    final replyToMessageId = state.replyingTo?.messageId;

    emit(state.copyWith(sending: true, errorMessage: null));
    try {
      final message = await _chatRepository.sendGeneralMessage(
        eventID: _eventID,
        body: trimmed,
        clientMsgId: '${DateTime.now().microsecondsSinceEpoch}',
        replyToMessageId: replyToMessageId,
      );
      emit(
        state.copyWith(
          sending: false,
          replyingTo: null,
          messages: _upsertMessage(state.messages, message),
        ),
      );
    } on ChatFailure catch (failure, stackTrace) {
      addError(failure, stackTrace);
      emit(
        state.copyWith(
          sending: false,
          errorMessage: failure.toDisplayMessage(),
        ),
      );
    } on Object catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(
        state.copyWith(
          sending: false,
          errorMessage: ChatUnknownError().toDisplayMessage(),
        ),
      );
    }
  }

  Future<void> deleteMessage(String messageId) async {
    try {
      await _chatRepository.deleteMessage(
        eventID: _eventID,
        messageID: messageId,
      );
      emit(
        state.copyWith(
          messages: _removeMessage(state.messages, messageId),
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

  Future<void> toggleReaction({
    required String messageId,
    required String emoji,
  }) async {
    final index = state.messages.indexWhere((m) => m.messageId == messageId);
    if (index < 0) return;

    final message = state.messages[index];
    final existing = message.reactions?.where(
      (r) => r.reactedByMe && r.emoji == emoji,
    ).firstOrNull;

    try {
      final reactions = existing != null
          ? await _chatRepository.removeMessageReaction(
              eventID: _eventID,
              messageID: messageId,
            )
          : await _chatRepository.setMessageReaction(
              eventID: _eventID,
              messageID: messageId,
              emoji: emoji,
            );
      emit(
        state.copyWith(
          messages: _updateReactions(state.messages, messageId, reactions),
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

  void clearError() {
    if (state.errorMessage != null) {
      emit(state.copyWith(errorMessage: null));
    }
  }

  void startReply(ChatMessage message) {
    emit(state.copyWith(replyingTo: message));
  }

  void cancelReply() {
    if (state.replyingTo != null) {
      emit(state.copyWith(replyingTo: null));
    }
  }

  @override
  Future<void> close() {
    _realtimeHandle?.cancel();
    return super.close();
  }
}

List<ChatMessage> _upsertMessage(
  List<ChatMessage> messages,
  ChatMessage message,
) {
  if (messages.any((m) => m.messageId == message.messageId)) {
    return messages;
  }
  return [...messages, message];
}

List<ChatMessage> _mergeOlderMessages(
  List<ChatMessage> current,
  List<ChatMessage> older,
) {
  final existingIds = current.map((m) => m.messageId).toSet();
  final uniqueOlder = older.where((m) => !existingIds.contains(m.messageId));
  return [...uniqueOlder, ...current];
}

List<ChatMessage> _removeMessage(
  List<ChatMessage> messages,
  String messageId,
) {
  return messages.where((m) => m.messageId != messageId).toList();
}

List<ChatMessage> _updateReactions(
  List<ChatMessage> messages,
  String messageId,
  List<ChatReaction> reactions,
) {
  return messages
      .map(
        (m) => m.messageId == messageId
            ? ChatMessage(
                messageId: m.messageId,
                eventId: m.eventId,
                channelType: m.channelType,
                senderUserId: m.senderUserId,
                body: m.body,
                createdAt: m.createdAt,
                conversationId: m.conversationId,
                senderName: m.senderName,
                senderLastName: m.senderLastName,
                senderProfilePictureUrl: m.senderProfilePictureUrl,
                recipientUserId: m.recipientUserId,
                replyTo: m.replyTo,
                reactions: reactions.isEmpty ? null : reactions,
              )
            : m,
      )
      .toList();
}
