import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import 'package:m3t_api/src/models/room.dart';
import 'package:m3t_api/src/models/session.dart';

part 'room_with_sessions.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
final class RoomWithSessions extends Equatable {
  const RoomWithSessions({
    required this.room,
    required this.sessions,
  });

  factory RoomWithSessions.fromJson(Map<String, dynamic> json) =>
      _$RoomWithSessionsFromJson(json);

  final Room room;
  final List<Session> sessions;

  Map<String, dynamic> toJson() => _$RoomWithSessionsToJson(this);

  @override
  List<Object?> get props => [room, sessions];
}
