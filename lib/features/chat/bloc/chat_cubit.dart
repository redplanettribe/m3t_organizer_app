import 'dart:async';

import 'package:domain/domain.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'chat_state.dart';

/// Chat feature — tab selection and shared DM inbox WebSocket subscription.
final class ChatCubit extends Cubit<ChatState> {
  ChatCubit({
    required ChatRepository chatRepository,
    required String eventID,
  }) : _chatRepository = chatRepository,
       _eventID = eventID,
       super(const ChatState()) {
    _connectRealtime();
  }

  final ChatRepository _chatRepository;
  final String _eventID;
  final _realtimeController = StreamController<ChatRealtimeEvent>.broadcast();
  ChatRealtimeHandle? _realtimeHandle;

  /// Broadcast stream of multiplexed chat events (DM inbox topic).
  Stream<ChatRealtimeEvent> get realtimeEvents => _realtimeController.stream;

  void _connectRealtime() {
    final eventIdLower = _eventID.toLowerCase();
    _realtimeHandle = _chatRepository.connectChatRealtime(
      eventID: _eventID,
      topics: ['attendee.chat.$eventIdLower.dm.inbox'],
      onEvent: _realtimeController.add,
      onError: (error) => addError(error, StackTrace.current),
    );
    emit(state.copyWith(dmInboxConnected: true));
  }

  void selectChannel(ChatChannelTab tab) {
    emit(state.copyWith(selectedTab: tab));
  }

  @override
  Future<void> close() {
    _realtimeHandle?.cancel();
    unawaited(_realtimeController.close());
    return super.close();
  }
}

enum ChatChannelTab {
  general,
  dms,
  organizers,
}
