import 'package:auth_repository/src/mappers/event_mapper.dart';
import 'package:auth_repository/src/mappers/room_with_sessions_mapper.dart';
import 'package:domain/domain.dart' as domain;
import 'package:m3t_api/m3t_api.dart' as api;

extension ApiGetEventByIdResponseMapper on api.GetEventByIdResponse {
  domain.EventWithRooms toDomain() => domain.EventWithRooms(
    event: event.toDomain(),
    rooms: rooms.map((r) => r.toDomain()).toList(),
  );
}
