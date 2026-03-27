// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deliverable_giveaway.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeliverableGiveaway _$DeliverableGiveawayFromJson(Map<String, dynamic> json) =>
    DeliverableGiveaway(
      id: json['id'] as String,
      eventId: json['event_id'] as String,
      deliverableId: json['deliverable_id'] as String,
      userId: json['user_id'] as String,
      givenBy: json['given_by'] as String,
      createdAt: json['created_at'] as String,
      name: json['name'] as String?,
      lastName: json['last_name'] as String?,
      email: json['email'] as String?,
      deliverableName: json['deliverable_name'] as String?,
      user: json['user'] == null
          ? null
          : User.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DeliverableGiveawayToJson(
  DeliverableGiveaway instance,
) => <String, dynamic>{
  'id': instance.id,
  'event_id': instance.eventId,
  'deliverable_id': instance.deliverableId,
  'user_id': instance.userId,
  'given_by': instance.givenBy,
  'name': instance.name,
  'last_name': instance.lastName,
  'email': instance.email,
  'deliverable_name': instance.deliverableName,
  'created_at': instance.createdAt,
  'user': instance.user,
};
