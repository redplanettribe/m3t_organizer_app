import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:m3t_api/src/models/event_registration_tier_info.dart';

part 'event_registration.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
final class EventRegistration extends Equatable {
  const EventRegistration({
    required this.registrationId,
    required this.eventId,
    required this.userId,
    this.name,
    this.lastName,
    this.email,
    this.checkedIn,
    this.createdAt,
    this.updatedAt,
    this.tier,
  });

  factory EventRegistration.fromJson(Map<String, dynamic> json) =>
      _$EventRegistrationFromJson(json);

  final String registrationId;
  final String eventId;
  final String userId;
  final String? name;
  final String? lastName;
  final String? email;
  final bool? checkedIn;
  final String? createdAt;
  final String? updatedAt;
  final EventRegistrationTierInfo? tier;

  Map<String, dynamic> toJson() => _$EventRegistrationToJson(this);

  @override
  List<Object?> get props => [
    registrationId,
    eventId,
    userId,
    name,
    lastName,
    email,
    checkedIn,
    createdAt,
    updatedAt,
    tier,
  ];
}
