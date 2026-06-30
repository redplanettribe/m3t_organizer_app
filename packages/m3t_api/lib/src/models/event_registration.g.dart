// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_registration.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EventRegistration _$EventRegistrationFromJson(Map<String, dynamic> json) =>
    EventRegistration(
      registrationId: json['registration_id'] as String,
      eventId: json['event_id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String?,
      lastName: json['last_name'] as String?,
      email: json['email'] as String?,
      checkedIn: json['checked_in'] as bool?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      tier: json['tier'] == null
          ? null
          : EventRegistrationTierInfo.fromJson(
              json['tier'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$EventRegistrationToJson(EventRegistration instance) =>
    <String, dynamic>{
      'registration_id': instance.registrationId,
      'event_id': instance.eventId,
      'user_id': instance.userId,
      'name': instance.name,
      'last_name': instance.lastName,
      'email': instance.email,
      'checked_in': instance.checkedIn,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
      'tier': instance.tier,
    };
