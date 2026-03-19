// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Session _$SessionFromJson(Map<String, dynamic> json) => Session(
  id: json['id'] as String,
  roomId: json['room_id'] as String,
  title: json['title'] as String,
  eventDay: (json['event_day'] as num).toInt(),
  startTime: json['start_time'] as String,
  endTime: json['end_time'] as String,
  description: json['description'] as String?,
  source: json['source'] as String?,
  sourceSessionId: json['source_session_id'] as String?,
  createdAt: json['created_at'] as String?,
  updatedAt: json['updated_at'] as String?,
);

Map<String, dynamic> _$SessionToJson(Session instance) => <String, dynamic>{
  'id': instance.id,
  'room_id': instance.roomId,
  'title': instance.title,
  'event_day': instance.eventDay,
  'start_time': instance.startTime,
  'end_time': instance.endTime,
  'description': instance.description,
  'source': instance.source,
  'source_session_id': instance.sourceSessionId,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
};
