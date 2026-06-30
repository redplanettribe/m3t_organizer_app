// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_registration_page.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EventRegistrationPage _$EventRegistrationPageFromJson(
  Map<String, dynamic> json,
) => EventRegistrationPage(
  items: (json['items'] as List<dynamic>)
      .map((e) => EventRegistration.fromJson(e as Map<String, dynamic>))
      .toList(),
  pagination: json['pagination'] == null
      ? null
      : PaginationMeta.fromJson(json['pagination'] as Map<String, dynamic>),
);

Map<String, dynamic> _$EventRegistrationPageToJson(
  EventRegistrationPage instance,
) => <String, dynamic>{
  'items': instance.items,
  'pagination': instance.pagination,
};
