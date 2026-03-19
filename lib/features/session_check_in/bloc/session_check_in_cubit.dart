import 'package:domain/domain.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m3t_organizer/core/events/events_failure_message.dart';

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

  final Set<String> _successfullyCheckedInUserIds = {};

  Future<void> onUserIDScanned(String userID) async {
    final normalizedUserID = userID.trim();
    if (normalizedUserID.isEmpty || state.loading) {
      return;
    }

    if (_successfullyCheckedInUserIds.contains(normalizedUserID)) {
      emit(
        state.copyWith(
          lastScannedUserId: normalizedUserID,
          scanFeedbackNonce: state.scanFeedbackNonce + 1,
          errorMessage: null,
        ),
      );
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
      final checkIn = await _eventsRepository.checkInAttendeeToSession(
        eventID: _eventID,
        sessionID: _sessionID,
        userID: normalizedUserID,
      );
      _successfullyCheckedInUserIds.add(normalizedUserID);
      emit(
        state.copyWith(
          loading: false,
          latestCheckIn: checkIn,
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
}
