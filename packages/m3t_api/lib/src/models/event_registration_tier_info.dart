import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'event_registration_tier_info.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
final class EventRegistrationTierInfo extends Equatable {
  const EventRegistrationTierInfo({
    required this.id,
    required this.name,
    this.color,
  });

  factory EventRegistrationTierInfo.fromJson(Map<String, dynamic> json) =>
      _$EventRegistrationTierInfoFromJson(json);

  final String id;
  final String name;
  final String? color;

  Map<String, dynamic> toJson() => _$EventRegistrationTierInfoToJson(this);

  @override
  List<Object?> get props => [id, name, color];
}
