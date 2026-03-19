import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'event_check_in.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
final class EventCheckIn extends Equatable {
  const EventCheckIn({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.checkedInBy,
    required this.createdAt,
    this.name,
    this.lastName,
    this.email,
  });

  factory EventCheckIn.fromJson(Map<String, dynamic> json) =>
      _$EventCheckInFromJson(json);

  final String id;
  final String eventId;
  final String userId;
  final String checkedInBy;
  final String? name;
  final String? lastName;
  final String? email;
  final String createdAt;

  Map<String, dynamic> toJson() => _$EventCheckInToJson(this);

  @override
  List<Object?> get props => [
    id,
    eventId,
    userId,
    checkedInBy,
    name,
    lastName,
    email,
    createdAt,
  ];
}
