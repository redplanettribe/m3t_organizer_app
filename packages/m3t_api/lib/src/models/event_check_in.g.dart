// GENERATED CODE - MANUAL STUB FOR json_serializable

part of 'event_check_in.dart';

EventCheckIn _$EventCheckInFromJson(Map<String, dynamic> json) => EventCheckIn(
  id: json['id'] as String,
  eventId: json['event_id'] as String,
  userId: json['user_id'] as String,
  checkedInBy: json['checked_in_by'] as String,
  createdAt: json['created_at'] as String,
  name: json['name'] as String?,
  lastName: json['last_name'] as String?,
  email: json['email'] as String?,
);

Map<String, dynamic> _$EventCheckInToJson(EventCheckIn instance) =>
    <String, dynamic>{
      'id': instance.id,
      'event_id': instance.eventId,
      'user_id': instance.userId,
      'checked_in_by': instance.checkedInBy,
      'name': instance.name,
      'last_name': instance.lastName,
      'email': instance.email,
      'created_at': instance.createdAt,
    };
