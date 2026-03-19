part of 'session_selector_cubit.dart';

final class SessionSelectorState extends Equatable {
  const SessionSelectorState({
    this.loading = false,
    this.errorMessage,
    this.rooms = const <RoomWithSessions>[],
    this.selectedSessionId,
    this.selectedSession,
    this.selectedRoomName,
  });

  final bool loading;
  final String? errorMessage;
  final List<RoomWithSessions> rooms;
  final String? selectedSessionId;
  final Session? selectedSession;
  final String? selectedRoomName;

  static const _sentinel = Object();

  SessionSelectorState copyWith({
    bool? loading,
    Object? errorMessage = _sentinel,
    List<RoomWithSessions>? rooms,
    Object? selectedSessionId = _sentinel,
    Object? selectedSession = _sentinel,
    Object? selectedRoomName = _sentinel,
  }) {
    return SessionSelectorState(
      loading: loading ?? this.loading,
      errorMessage: errorMessage == _sentinel
          ? this.errorMessage
          : errorMessage as String?,
      rooms: rooms ?? this.rooms,
      selectedSessionId: selectedSessionId == _sentinel
          ? this.selectedSessionId
          : selectedSessionId as String?,
      selectedSession: selectedSession == _sentinel
          ? this.selectedSession
          : selectedSession as Session?,
      selectedRoomName: selectedRoomName == _sentinel
          ? this.selectedRoomName
          : selectedRoomName as String?,
    );
  }

  @override
  List<Object?> get props => [
    loading,
    errorMessage,
    rooms,
    selectedSessionId,
    selectedSession,
    selectedRoomName,
  ];
}
