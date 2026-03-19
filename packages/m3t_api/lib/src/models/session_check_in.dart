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
  });

  factory SessionCheckIn.fromJson(Map<String, dynamic> json) =>
      _$SessionCheckInFromJson(json);

  final String id;
  final String sessionId;
  final String userId;
  final String checkedInBy;
  final String createdAt;

  Map<String, dynamic> toJson() => _$SessionCheckInToJson(this);

  @override
  List<Object?> get props => [id, sessionId, userId, checkedInBy, createdAt];
}
