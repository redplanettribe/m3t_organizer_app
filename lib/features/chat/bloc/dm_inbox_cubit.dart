import 'dart:async';

import 'package:domain/domain.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m3t_organizer/core/chat/chat_failure_message.dart';
import 'package:m3t_organizer/core/events/events_failure_message.dart';

part 'dm_inbox_state.dart';

/// DM inbox: conversation list, pagination, and inbox WS updates.
final class DmInboxCubit extends Cubit<DmInboxState> {
  DmInboxCubit({
    required ChatRepository chatRepository,
    required EventsRepository eventsRepository,
    required String eventID,
    required Stream<ChatRealtimeEvent> realtimeEvents,
    String? currentUserId,
    void Function(String messageId)? onMessageDeliveredViaRealtime,
    bool autoInitialize = true,
  }) : _chatRepository = chatRepository,
       _eventsRepository = eventsRepository,
       _eventID = eventID,
       _currentUserId = currentUserId,
       _onMessageDeliveredViaRealtime = onMessageDeliveredViaRealtime,
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
  final EventsRepository _eventsRepository;
  final String _eventID;
  final String? _currentUserId;
  final void Function(String messageId)? _onMessageDeliveredViaRealtime;
  static const _pageSize = 50;
  static const _searchPageSize = 20;

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
      final conversations = await _enrichConversations(page.items);
      emit(
        state.copyWith(
          loading: false,
          conversations: conversations,
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
      final merged = _mergeConversations(state.conversations, page.items);
      final conversations = await _enrichConversations(merged);
      emit(
        state.copyWith(
          loadingMore: false,
          conversations: conversations,
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
        _onMessageDeliveredViaRealtime?.call(message.messageId);
        final conversations = _upsertConversation(state.conversations, message);
        emit(state.copyWith(conversations: conversations));
        unawaited(_enrichMissingNames(conversations));
        return;
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
    final existing = index >= 0 ? conversations[index] : null;
    final otherUserId =
        existing?.otherUserId ?? _otherUserIdFromMessage(message);
    final displayName = _displayNameForOther(
      otherUserId: otherUserId,
      lastMessage: message,
      existingName: existing?.otherParticipantDisplayName,
    );

    final updated = ChatConversation(
      conversationId: conversationId,
      otherUserId: otherUserId,
      lastMessage: message,
      otherParticipantDisplayName: displayName,
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
    return conversations.map((conversation) {
      if (conversationId != null &&
          conversation.conversationId != conversationId) {
        return conversation;
      }
      final last = conversation.lastMessage;
      if (last?.messageId != messageId) return conversation;
      return ChatConversation(
        conversationId: conversation.conversationId,
        otherUserId: conversation.otherUserId,
        otherParticipantDisplayName: conversation.otherParticipantDisplayName,
      );
    }).toList();
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
        pageSize: _searchPageSize,
      );
      final selfId = _currentUserId;
      if (selfId == null) {
        return page.items;
      }
      return page.items.where((r) => r.userId != selfId).toList();
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

  Future<List<ChatConversation>> _enrichConversations(
    List<ChatConversation> conversations,
  ) async {
    final withKnownNames = _applyKnownDisplayNames(conversations, const {});
    final needsLookup = _userIdsNeedingLookup(withKnownNames);
    if (needsLookup.isEmpty) {
      return withKnownNames;
    }

    try {
      final resolved = await _lookupRegistrationDisplayNames(needsLookup);
      return _applyKnownDisplayNames(withKnownNames, resolved);
    } on EventsFailure catch (failure, stackTrace) {
      addError(failure, stackTrace);
      return withKnownNames;
    } on Object catch (error, stackTrace) {
      addError(error, stackTrace);
      return withKnownNames;
    }
  }

  Future<void> _enrichMissingNames(List<ChatConversation> conversations) async {
    final needsLookup = _userIdsNeedingLookup(conversations);
    if (needsLookup.isEmpty) {
      return;
    }

    try {
      final resolved = await _lookupRegistrationDisplayNames(needsLookup);
      if (isClosed) {
        return;
      }
      emit(
        state.copyWith(
          conversations: _applyKnownDisplayNames(
            state.conversations,
            resolved,
          ),
        ),
      );
    } on Object catch (error, stackTrace) {
      addError(error, stackTrace);
    }
  }

  Future<Map<String, String>> _lookupRegistrationDisplayNames(
    Set<String> userIds,
  ) async {
    final names = <String, String>{};
    final unresolved = Set<String>.from(userIds);
    if (unresolved.isEmpty) {
      return names;
    }

    var page = 1;
    const pageSize = 100;
    while (unresolved.isNotEmpty) {
      final result = await _eventsRepository.listEventRegistrations(
        eventID: _eventID,
        page: page,
        pageSize: pageSize,
      );

      for (final registration in result.items) {
        if (unresolved.remove(registration.userId)) {
          names[registration.userId] = registration.displayName;
        }
      }

      if (result.items.length < pageSize) {
        break;
      }
      final totalPages = result.totalPages;
      if (totalPages != null && page >= totalPages) {
        break;
      }
      page++;
    }

    return names;
  }

  List<ChatConversation> _applyKnownDisplayNames(
    List<ChatConversation> conversations,
    Map<String, String> resolvedNames,
  ) {
    return conversations
        .map(
          (conversation) => ChatConversation(
            conversationId: conversation.conversationId,
            otherUserId: conversation.otherUserId,
            lastMessage: conversation.lastMessage,
            otherParticipantDisplayName: _displayNameForOther(
              otherUserId: conversation.otherUserId,
              lastMessage: conversation.lastMessage,
              existingName: conversation.otherParticipantDisplayName,
              resolvedNames: resolvedNames,
            ),
          ),
        )
        .toList();
  }

  Set<String> _userIdsNeedingLookup(List<ChatConversation> conversations) {
    return conversations
        .where((conversation) => !_hasDisplayName(conversation))
        .map((conversation) => conversation.otherUserId)
        .toSet();
  }

  bool _hasDisplayName(ChatConversation conversation) {
    final name = conversation.otherParticipantDisplayName;
    return name != null &&
        name.trim().isNotEmpty &&
        name != conversation.otherUserId;
  }

  String? _displayNameForOther({
    required String otherUserId,
    required ChatMessage? lastMessage,
    String? existingName,
    Map<String, String> resolvedNames = const {},
  }) {
    if (existingName != null &&
        existingName.trim().isNotEmpty &&
        existingName != otherUserId) {
      return existingName;
    }

    final selfId = _currentUserId;
    if (lastMessage != null &&
        selfId != null &&
        lastMessage.senderUserId != selfId) {
      final fromMessage = _displayNameFromMessageSender(lastMessage);
      if (fromMessage != null) {
        return fromMessage;
      }
    }

    return resolvedNames[otherUserId];
  }

  String? _displayNameFromMessageSender(ChatMessage message) {
    final name = [
      message.senderName,
      message.senderLastName,
    ].whereType<String>().where((part) => part.trim().isNotEmpty).join(' ');
    return name.isEmpty ? null : name;
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
