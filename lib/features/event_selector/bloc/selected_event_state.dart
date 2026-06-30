part of 'selected_event_cubit.dart';

/// Immutable state for the selected-event feature.
final class SelectedEventState extends Equatable {
  const SelectedEventState({
    this.events = const <Event>[],
    this.selectedEvent,
    this.loading = false,
    this.errorMessage,
  });

  final List<Event> events;
  final Event? selectedEvent;
  final bool loading;
  final String? errorMessage;

  static const _sentinel = Object();

  SelectedEventState copyWith({
    List<Event>? events,
    Object? selectedEvent = _sentinel,
    bool? loading,
    Object? errorMessage = _sentinel,
  }) {
    return SelectedEventState(
      events: events ?? this.events,
      selectedEvent: selectedEvent == _sentinel
          ? this.selectedEvent
          : selectedEvent as Event?,
      loading: loading ?? this.loading,
      errorMessage: errorMessage == _sentinel
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  @override
  List<Object?> get props => [events, selectedEvent, loading, errorMessage];
}
