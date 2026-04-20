import 'package:domain/domain.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m3t_organizer/core/events/events_failure_message.dart';
import 'package:m3t_organizer/features/session_check_in/bloc/session_check_in_failure_message.dart';

part 'session_check_in_state.dart';

final class SessionCheckInCubit extends Cubit<SessionCheckInState> {
  SessionCheckInCubit({
    required String eventID,
    required String sessionID,
    required EventsRepository eventsRepository,
  }) : _eventID = eventID,
       _sessionID = sessionID,
       _eventsRepository = eventsRepository,
       super(const SessionCheckInState());

  final String _eventID;
  final String _sessionID;
  final EventsRepository _eventsRepository;

  Future<void> onUserIDScanned(String userID) async {
    final normalizedUserID = userID.trim();
    if (normalizedUserID.isEmpty || state.loading) {
      return;
    }

    emit(
      state.copyWith(
        loading: true,
        errorMessage: null,
        lastScannedUserId: normalizedUserID,
      ),
    );

    try {
      final result = await _eventsRepository.checkInAttendeeToSession(
        eventID: _eventID,
        sessionID: _sessionID,
        userID: normalizedUserID,
      );
      emit(
        state.copyWith(
          loading: false,
          latestCheckIn: result.checkIn,
          errorMessage: null,
          // Bumping the nonce on idempotent (already-checked-in) scans lets
          // the scanner flash an "Already checked in" banner even when
          // [latestCheckIn] is unchanged.
          scanFeedbackNonce: result.alreadyCheckedIn
              ? state.scanFeedbackNonce + 1
              : state.scanFeedbackNonce,
        ),
      );
    } on EventsFailure catch (failure, stackTrace) {
      addError(failure, stackTrace);
      emit(
        state.copyWith(
          loading: false,
          errorMessage: failure.toSessionCheckInMessage(),
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
}
