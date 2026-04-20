import 'package:domain/domain.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m3t_organizer/core/events/events_failure_message.dart';
import 'package:m3t_organizer/features/check_in_event/bloc/event_check_in_failure_message.dart';

part 'check_in_event_state.dart';

final class CheckInEventCubit extends Cubit<CheckInEventState> {
  CheckInEventCubit({
    required String eventID,
    required EventsRepository eventsRepository,
  }) : _eventID = eventID,
       _eventsRepository = eventsRepository,
       super(const CheckInEventState());

  final String _eventID;
  final EventsRepository _eventsRepository;

  DateTime? _lastScanAt;
  String? _lastScannedUserID;

  static const _duplicateScanCooldown = Duration(seconds: 2);

  Future<void> onUserIDScanned(String userID) async {
    final normalizedUserID = userID.trim();
    if (normalizedUserID.isEmpty || state.loading) {
      return;
    }

    final now = DateTime.now();
    if (_lastScannedUserID == normalizedUserID &&
        _lastScanAt != null &&
        now.difference(_lastScanAt!) < _duplicateScanCooldown) {
      return;
    }

    _lastScannedUserID = normalizedUserID;
    _lastScanAt = now;
    emit(
      state.copyWith(
        loading: true,
        errorMessage: null,
        lastScannedUserId: normalizedUserID,
      ),
    );

    try {
      final result = await _eventsRepository.checkInAttendee(
        eventID: _eventID,
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
          errorMessage: failure.toEventCheckInMessage(),
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
