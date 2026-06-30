import 'package:domain/domain.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m3t_organizer/core/events/events_failure_message.dart';
import 'package:m3t_organizer/features/event_selector/data/selected_event_storage.dart';

part 'selected_event_state.dart';

/// Loads team events and tracks the user's selected event.
final class SelectedEventCubit extends Cubit<SelectedEventState> {
  SelectedEventCubit({
    required EventsRepository eventsRepository,
    required SelectedEventStorage selectedEventStorage,
  }) : _eventsRepository = eventsRepository,
       _selectedEventStorage = selectedEventStorage,
       super(const SelectedEventState());

  final EventsRepository _eventsRepository;
  final SelectedEventStorage _selectedEventStorage;

  /// Loads managed events and restores or defaults the selected event.
  Future<void> loadEvents() async {
    emit(state.copyWith(loading: true, errorMessage: null));

    try {
      final events = await _eventsRepository.getMyEvents();
      final persistedId = await _selectedEventStorage.read();
      final selectedEvent = _resolveSelectedEvent(
        events: events,
        persistedId: persistedId,
      );

      if (selectedEvent != null) {
        await _selectedEventStorage.write(selectedEvent.id);
      } else {
        await _selectedEventStorage.clear();
      }

      emit(
        state.copyWith(
          loading: false,
          events: events,
          selectedEvent: selectedEvent,
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

  /// Selects [event] and persists its id.
  Future<void> selectEvent(Event event) async {
    if (state.selectedEvent?.id == event.id) {
      return;
    }

    emit(state.copyWith(selectedEvent: event, errorMessage: null));

    try {
      await _selectedEventStorage.write(event.id);
    } on Object catch (error, stackTrace) {
      addError(error, stackTrace);
    }
  }

  /// Clears selection and loaded events (e.g. on logout).
  void reset() {
    emit(const SelectedEventState());
  }

  Event? _resolveSelectedEvent({
    required List<Event> events,
    required String? persistedId,
  }) {
    if (events.isEmpty) {
      return null;
    }

    if (persistedId != null) {
      for (final event in events) {
        if (event.id == persistedId) {
          return event;
        }
      }
    }

    return events.first;
  }
}
