import 'package:domain/src/entities/event.dart';
import 'package:domain/src/entities/room_with_sessions.dart';
import 'package:equatable/equatable.dart';

/// Domain representation of an event with its nested rooms and sessions.
final class EventWithRooms extends Equatable {
  const EventWithRooms({
    required this.event,
    required this.rooms,
  });

  final Event event;
  final List<RoomWithSessions> rooms;

  @override
  List<Object?> get props => [event, rooms];
}
