// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_deliverable.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EventDeliverable _$EventDeliverableFromJson(Map<String, dynamic> json) =>
    EventDeliverable(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
    );

Map<String, dynamic> _$EventDeliverableToJson(EventDeliverable instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
    };
