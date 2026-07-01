import 'dart:async';

import 'package:domain/domain.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m3t_organizer/features/chat/bloc/chat_cubit.dart';

part 'chat_unread_state.dart';

/// Tracks per-channel unread counts from multiplexed chat WebSocket topics.
final class ChatUnreadCubit extends Cubit<ChatUnreadState> {
  ChatUnreadCubit({
    required ChatRepository chatRepository,
    required String eventID,
    String? currentUserId,
  }) : _chatRepository = chatRepository,
       _eventID = eventID,
       _currentUserId = currentUserId,
       super(const ChatUnreadState()) {
    _connectRealtime();
  }

  final ChatRepository _chatRepository;
  final String _eventID;
  String? _currentUserId;
  ChatRealtimeHandle? _realtimeHandle;
  final _countedMessageIds = <String>{};

  bool _chatNavActive = false;
  ChatChannelTab? _activeSegmentedTab;
  String? _openDmConversationId;

  void _connectRealtime() {
    final eventIdLower = _eventID.toLowerCase();
    _realtimeHandle = _chatRepository.connectChatRealtime(
      eventID: _eventID,
      topics: [
        'attendee.chat.$eventIdLower.general',
        'organizer.chat.$eventIdLower',
        'attendee.chat.$eventIdLower.dm.inbox',
      ],
      onEvent: _onRealtimeEvent,
      onError: (error) => addError(error, StackTrace.current),
    );
  }

  void setCurrentUserId(String? userId) {
    _currentUserId = userId;
  }

  void setChatNavActive({required bool active}) {
    _chatNavActive = active;
    if (active && _activeSegmentedTab != null) {
      _maybeClearChannelOnFocus(_activeSegmentedTab!);
    }
  }

  void setActiveSegmentedTab(ChatChannelTab tab) {
    _activeSegmentedTab = tab;
    if (_chatNavActive) {
      _maybeClearChannelOnFocus(tab);
    }
  }

  void setOpenDmConversation(String? conversationId) {
    _openDmConversationId = conversationId?.toLowerCase();
  }

  void markDmConversationRead(String conversationId) {
    final key = conversationId.toLowerCase();
    if (!state.dmUnreadByConversation.containsKey(key)) {
      return;
    }
    final updated = Map<String, int>.from(state.dmUnreadByConversation)
      ..remove(key);
    emit(state.copyWith(dmUnreadByConversation: updated));
  }

  void _maybeClearChannelOnFocus(ChatChannelTab tab) {
    switch (tab) {
      case ChatChannelTab.general:
        if (state.generalUnread > 0) {
          emit(state.copyWith(generalUnread: 0));
        }
      case ChatChannelTab.organizers:
        if (state.organizersUnread > 0) {
          emit(state.copyWith(organizersUnread: 0));
        }
      case ChatChannelTab.dms:
      case ChatChannelTab.banned:
        break;
    }
  }

  void _onRealtimeEvent(ChatRealtimeEvent event) {
    if (event is! ChatMessageReceived) {
      return;
    }
    handleMessageForTest(event.message);
  }

  @visibleForTesting
  void handleMessageForTest(ChatMessage message) {
    final currentUserId = _currentUserId;
    if (currentUserId == null) {
      return;
    }
    if (message.senderUserId == currentUserId) {
      return;
    }
    if (_countedMessageIds.contains(message.messageId)) {
      return;
    }
    if (_isViewingContext(message)) {
      return;
    }

    _countedMessageIds.add(message.messageId);

    switch (message.channelType) {
      case ChatChannelType.general:
        emit(state.copyWith(generalUnread: state.generalUnread + 1));
      case ChatChannelType.organizers:
        emit(state.copyWith(organizersUnread: state.organizersUnread + 1));
      case ChatChannelType.dm:
        final conversationId = message.conversationId;
        if (conversationId == null) {
          return;
        }
        final key = conversationId.toLowerCase();
        final updated = Map<String, int>.from(state.dmUnreadByConversation);
        updated[key] = (updated[key] ?? 0) + 1;
        emit(state.copyWith(dmUnreadByConversation: updated));
    }
  }

  bool _isViewingContext(ChatMessage message) {
    if (!_chatNavActive) {
      return false;
    }

    return switch (message.channelType) {
      ChatChannelType.general => _activeSegmentedTab == ChatChannelTab.general,
      ChatChannelType.organizers =>
        _activeSegmentedTab == ChatChannelTab.organizers,
      ChatChannelType.dm =>
        _activeSegmentedTab == ChatChannelTab.dms &&
            message.conversationId?.toLowerCase() == _openDmConversationId,
    };
  }

  @override
  Future<void> close() {
    _realtimeHandle?.cancel();
    return super.close();
  }
}
