part of 'my_events_cubit.dart';

/// Immutable state for the managed-events feature.
final class MyEventsState extends Equatable {
  const MyEventsState({
    this.events = const <Event>[],
    this.loading = false,
    this.errorMessage,
  });

  final List<Event> events;
  final bool loading;
  final String? errorMessage;

  static const _sentinel = Object();

  MyEventsState copyWith({
    List<Event>? events,
    bool? loading,
    Object? errorMessage = _sentinel,
  }) {
    return MyEventsState(
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

//
