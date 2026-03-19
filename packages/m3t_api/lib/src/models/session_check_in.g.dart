// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_check_in.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SessionCheckIn _$SessionCheckInFromJson(Map<String, dynamic> json) =>
    SessionCheckIn(
      id: json['id'] as String,
      sessionId: json['session_id'] as String,
      userId: json['user_id'] as String,
      checkedInBy: json['checked_in_by'] as String,
      createdAt: json['created_at'] as String,
    );

Map<String, dynamic> _$SessionCheckInToJson(SessionCheckIn instance) =>
    <String, dynamic>{
      'id': instance.id,
      'session_id': instance.sessionId,
      'user_id': instance.userId,
      'checked_in_by': instance.checkedInBy,
      'created_at': instance.createdAt,
    };
