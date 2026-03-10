import 'package:domain/domain.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m3t_organizer/core/managed_events/get_my_managed_events_failure_message.dart';

part 'events_state.dart';

/// Manages the list of events the current user manages (owner or team member).
final class EventsCubit extends Cubit<EventsState> {
  EventsCubit({required EventsRepository eventsRepository})
      : _eventsRepository = eventsRepository,
        super(const EventsState());

  final EventsRepository _eventsRepository;

  /// Loads the current user's managed events.
  Future<void> loadManagedEvents() async {
    emit(state.copyWith(loading: true, errorMessage: null));
    try {
      final events = await _eventsRepository.getMyManagedEvents();
      emit(state.copyWith(events: events, loading: false, errorMessage: null));
    } on GetMyManagedEventsFailure catch (failure, stackTrace) {
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
          errorMessage: GetMyManagedEventsUnknown().toDisplayMessage(),
        ),
      );
    }
  }
}
