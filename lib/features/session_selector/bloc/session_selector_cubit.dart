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
}
