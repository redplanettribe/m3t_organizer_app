part of 'events_cubit.dart';

/// Immutable state for the events (managed events list) feature.
final class EventsState extends Equatable {
  const EventsState({
    this.events = const [],
    this.loading = false,
    this.errorMessage,
  });

  final List<ManagedEventEntity> events;
  final bool loading;
  final String? errorMessage;

  static const _sentinel = Object();

  EventsState copyWith({
    List<ManagedEventEntity>? events,
    bool? loading,
    Object? errorMessage = _sentinel,
  }) {
    return EventsState(
      events: events ?? this.events,
      loading: loading ?? this.loading,
      errorMessage: errorMessage == _sentinel
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  @override
  List<Object?> get props => [events, loading, errorMessage];
}
