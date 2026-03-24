import 'package:domain/domain.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m3t_organizer/core/events/events_failure_message.dart';

part 'my_events_state.dart';

/// Loads and holds the events managed by the authenticated user.
final class MyEventsCubit extends Cubit<MyEventsState> {
  MyEventsCubit({required EventsRepository eventsRepository})
    : _eventsRepository = eventsRepository,
      super(const MyEventsState());

  final EventsRepository _eventsRepository;

  /// Loads managed events for the current user.
  ///
  /// When [silent] is true, the list is not replaced by the loading skeleton
  /// (for pull-to-refresh).
  Future<void> loadMyEvents({bool silent = false}) async {
    if (silent) {
      emit(state.copyWith(errorMessage: null));
    } else {
      emit(state.copyWith(loading: true, errorMessage: null));
    }

    try {
      final events = await _eventsRepository.getMyEvents();
      emit(
        state.copyWith(
          loading: false,
          events: events,
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

//
