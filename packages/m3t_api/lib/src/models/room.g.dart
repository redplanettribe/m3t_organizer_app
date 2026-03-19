// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'room.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Room _$RoomFromJson(Map<String, dynamic> json) => Room(
  id: json['id'] as String,
  eventId: json['event_id'] as String,
  name: json['name'] as String,
  capacity: (json['capacity'] as num).toInt(),
  notBookable: json['not_bookable'] as bool,
  description: json['description'] as String?,
  howToGetThere: json['how_to_get_there'] as String?,
  source: json['source'] as String?,
  sourceSessionId: (json['source_session_id'] as num?)?.toInt(),
  createdAt: json['created_at'] as String?,
  updatedAt: json['updated_at'] as String?,
);

Map<String, dynamic> _$RoomToJson(Room instance) => <String, dynamic>{
  'id': instance.id,
  'event_id': instance.eventId,
  'name': instance.name,
  'capacity': instance.capacity,
  'description': instance.description,
  'how_to_get_there': instance.howToGetThere,
  'not_bookable': instance.notBookable,
  'source': instance.source,
  'source_session_id': instance.sourceSessionId,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
};
