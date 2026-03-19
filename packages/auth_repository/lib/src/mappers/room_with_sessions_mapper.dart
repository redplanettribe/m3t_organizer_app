import 'package:auth_repository/src/mappers/room_mapper.dart';
import 'package:auth_repository/src/mappers/session_mapper.dart';
import 'package:domain/domain.dart' as domain;
import 'package:m3t_api/m3t_api.dart' as api;

extension ApiRoomWithSessionsMapper on api.RoomWithSessions {
  domain.RoomWithSessions toDomain() => domain.RoomWithSessions(
    room: room.toDomain(),
    sessions: sessions.map((s) => s.toDomain()).toList(),
  );
}
