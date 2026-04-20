import 'package:domain/domain.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m3t_organizer/core/events/events_failure_message.dart';

part 'session_selector_state.dart';

/// Loads the event rooms/sessions and manages the currently selected session.
final class SessionSelectorCubit extends Cubit<SessionSelectorState> {
  SessionSelectorCubit({
    required String eventID,
    required EventsRepository eventsRepository,
  }) : _eventID = eventID,
       _eventsRepository = eventsRepository,
       super(const SessionSelectorState());

  final String _eventID;
  final EventsRepository _eventsRepository;

  Future<void> loadEvent() async {
    emit(
      state.copyWith(
        loading: true,
        errorMessage: null,
      ),
    );

    try {
      final eventWithRooms = await _eventsRepository.getEventById(
        eventID: _eventID,
      );

      final rooms = eventWithRooms.rooms;

      emit(
        state.copyWith(
          loading: false,
          rooms: rooms,
          // Intentionally start with "no selection" so the organizer can
          // explicitly choose a session from the drawer.
          selectedSessionId: null,
          selectedSession: null,
          selectedRoomName: null,
          errorMessage: null,
        ),
      );
    } on EventsFailure catch (failure, stackTrace) {
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
          errorMessage: EventsUnknownError().toDisplayMessage(),
        ),
      );
    }
  }

  void selectSession(Session session) {
    if (state.rooms.isEmpty) return;

    for (final roomWithSessions in state.rooms) {
      final hasSession = roomWithSessions.sessions.any(
        (s) => s.id == session.id,
      );
      if (!hasSession) continue;

      emit(
        state.copyWith(
          selectedSessionId: session.id,
          selectedSession: session,
          selectedRoomName: roomWithSessions.room.name,
        ),
      );
      return;
    }
  }

  /// Merges a fresher [Session] (e.g. after status update) into the cached
  /// room/session list and the current selection when IDs match.
  void applySessionUpdate(Session updated) {
    var roomsChanged = false;
    final newRooms = <RoomWithSessions>[];

    for (final roomWithSessions in state.rooms) {
      final sessions = roomWithSessions.sessions;
      final index = sessions.indexWhere((s) => s.id == updated.id);
      if (index < 0) {
        newRooms.add(roomWithSessions);
        continue;
      }
      final current = sessions[index];
      if (current == updated) {
        newRooms.add(roomWithSessions);
        continue;
      }
      roomsChanged = true;
      final replaced = List<Session>.from(sessions);
      replaced[index] = updated;
      newRooms.add(
        RoomWithSessions(
          room: roomWithSessions.room,
          sessions: replaced,
        ),
      );
    }

    final matchSelected = state.selectedSessionId == updated.id;
    final shouldUpdateSelection =
        matchSelected && state.selectedSession != updated;

    if (!roomsChanged && !shouldUpdateSelection) return;

    emit(
      shouldUpdateSelection
          ? state.copyWith(
              rooms: roomsChanged ? newRooms : state.rooms,
              selectedSession: updated,
            )
          : state.copyWith(rooms: newRooms),
    );
  }
}
