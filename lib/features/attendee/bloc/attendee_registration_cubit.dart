import 'package:domain/domain.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m3t_organizer/core/events/events_failure_message.dart';

part 'attendee_registration_state.dart';

/// Loads a single event registration for an attendee profile screen.
final class AttendeeRegistrationCubit extends Cubit<AttendeeRegistrationState> {
  AttendeeRegistrationCubit({required EventsRepository eventsRepository})
    : _eventsRepository = eventsRepository,
      super(const AttendeeRegistrationState());

  final EventsRepository _eventsRepository;

  Future<void> load({
    required String eventID,
    required String userID,
  }) async {
    emit(
      state.copyWith(
        status: AttendeeRegistrationStatus.loading,
        errorMessage: null,
      ),
    );

    try {
      final registration = await _eventsRepository.getEventRegistrationByUserId(
        eventID: eventID,
        userID: userID,
      );

      if (registration == null) {
        emit(
          state.copyWith(
            status: AttendeeRegistrationStatus.notFound,
            registration: null,
            errorMessage: null,
          ),
        );
        return;
      }

      emit(
        state.copyWith(
          status: AttendeeRegistrationStatus.ready,
          registration: registration,
          errorMessage: null,
        ),
      );
    } on EventsFailure catch (failure, stackTrace) {
      addError(failure, stackTrace);
      emit(
        state.copyWith(
          status: AttendeeRegistrationStatus.failure,
          errorMessage: failure.toDisplayMessage(),
        ),
      );
    } on Object catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(
        state.copyWith(
          status: AttendeeRegistrationStatus.failure,
          errorMessage: EventsUnknownError().toDisplayMessage(),
        ),
      );
    }
  }
}
