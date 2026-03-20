import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'session_check_in.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
final class SessionCheckIn extends Equatable {
  const SessionCheckIn({
    required this.id,
    required this.sessionId,
    required this.userId,
    required this.checkedInBy,
    required this.createdAt,
    this.name,
    this.lastName,
    this.email,
  });

  factory SessionCheckIn.fromJson(Map<String, dynamic> json) =>
      _$SessionCheckInFromJson(json);

  final String id;
  final String sessionId;
  final String userId;
  final String checkedInBy;
  final String? name;
  final String? lastName;
  final String? email;
  final String createdAt;

  Map<String, dynamic> toJson() => _$SessionCheckInToJson(this);

  @override
  List<Object?> get props => [
    id,
    sessionId,
    userId,
    checkedInBy,
    name,
    lastName,
    email,
    createdAt,
  ];
}
