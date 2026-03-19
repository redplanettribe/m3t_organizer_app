import 'package:domain/src/entities/room.dart';
import 'package:domain/src/entities/session.dart';
import 'package:equatable/equatable.dart';

/// Domain representation of a room and its nested sessions.
final class RoomWithSessions extends Equatable {
  const RoomWithSessions({
    required this.room,
    required this.sessions,
  });

  final Room room;
  final List<Session> sessions;

  @override
  List<Object?> get props => [room, sessions];
}
