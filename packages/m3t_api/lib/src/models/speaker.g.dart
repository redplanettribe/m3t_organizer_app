// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'speaker.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Speaker _$SpeakerFromJson(Map<String, dynamic> json) => Speaker(
  id: json['id'] as String,
  firstName: json['first_name'] as String,
  lastName: json['last_name'] as String,
  isTopSpeaker: json['is_top_speaker'] as bool,
  bio: json['bio'] as String?,
  eventId: json['event_id'] as String?,
  phoneNumber: json['phone_number'] as String?,
  profilePicture: json['profile_picture'] as String?,
  source: json['source'] as String?,
  sourceSessionId: json['source_session_id'] as String?,
  tagLine: json['tag_line'] as String?,
  createdAt: json['created_at'] as String?,
  updatedAt: json['updated_at'] as String?,
);

Map<String, dynamic> _$SpeakerToJson(Speaker instance) => <String, dynamic>{
  'id': instance.id,
  'first_name': instance.firstName,
  'last_name': instance.lastName,
  'is_top_speaker': instance.isTopSpeaker,
  'bio': instance.bio,
  'event_id': instance.eventId,
  'phone_number': instance.phoneNumber,
  'profile_picture': instance.profilePicture,
  'source': instance.source,
  'source_session_id': instance.sourceSessionId,
  'tag_line': instance.tagLine,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
};
