import 'dart:async' show unawaited;

import 'package:domain/domain.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m3t_organizer/core/events/events_failure_message.dart';

part 'session_status_state.dart';

/// Loads session details and allows updating the session lifecycle status.
final class SessionStatusCubit extends Cubit<SessionStatusState> {
  SessionStatusCubit({
    required String eventID,
    required String sessionID,
    required EventsRepository eventsRepository,
  }) : _eventID = eventID,
       _sessionID = sessionID,
       _eventsRepository = eventsRepository,
       super(const SessionStatusState());

  final String _eventID;
  final String _sessionID;
  final EventsRepository _eventsRepository;

  Future<void> load() async {
    emit(
      state.copyWith(
        loading: true,
        updating: false,
        errorMessage: null,
      ),
    );

    try {
      final session = await _eventsRepository.getSessionById(
        sessionID: _sessionID,
      );
      emit(
        state.copyWith(
          loading: false,
          session: session,
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

  Future<void> changeStatus(SessionStatus status) async {
    if (state.updating || state.loading) return;

    emit(
      state.copyWith(
        updating: true,
        errorMessage: null,
      ),
    );

    try {
      final session = await _eventsRepository.updateSessionStatus(
        eventID: _eventID,
        sessionID: _sessionID,
        status: status,
      );

      emit(
        state.copyWith(
          updating: false,
          session: session,
          errorMessage: null,
        ),
      );
    } on EventsFailure catch (failure, stackTrace) {
      addError(failure, stackTrace);
      emit(
        state.copyWith(
          updating: false,
          errorMessage: failure.toDisplayMessage(),
        ),
      );
    } on Object catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(
        state.copyWith(
          updating: false,
          errorMessage: EventsUnknownError().toDisplayMessage(),
        ),
      );
    }
  }

  /// Helper for widget wiring.
  void loadUnawaited() {
    unawaited(load());
  }
}
