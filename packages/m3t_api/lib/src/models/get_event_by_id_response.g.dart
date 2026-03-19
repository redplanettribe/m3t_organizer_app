// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_event_by_id_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetEventByIdResponse _$GetEventByIdResponseFromJson(
  Map<String, dynamic> json,
) => GetEventByIdResponse(
  event: Event.fromJson(json['event'] as Map<String, dynamic>),
  rooms: (json['rooms'] as List<dynamic>)
      .map((e) => RoomWithSessions.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$GetEventByIdResponseToJson(
  GetEventByIdResponse instance,
) => <String, dynamic>{'event': instance.event, 'rooms': instance.rooms};
