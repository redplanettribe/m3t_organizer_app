import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import 'package:m3t_api/src/models/event.dart';
import 'package:m3t_api/src/models/room_with_sessions.dart';

part 'get_event_by_id_response.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
final class GetEventByIdResponse extends Equatable {
  const GetEventByIdResponse({
    required this.event,
    required this.rooms,
  });

  factory GetEventByIdResponse.fromJson(Map<String, dynamic> json) =>
      _$GetEventByIdResponseFromJson(json);

  final Event event;
  final List<RoomWithSessions> rooms;

  Map<String, dynamic> toJson() => _$GetEventByIdResponseToJson(this);

  @override
  List<Object?> get props => [event, rooms];
}
