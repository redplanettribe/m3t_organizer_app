import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'session.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
final class Session extends Equatable {
  const Session({
    required this.id,
    required this.roomId,
    required this.title,
    required this.eventDay,
    required this.startTime,
    required this.endTime,
    this.description,
    this.source,
    this.sourceSessionId,
    this.createdAt,
    this.updatedAt,
  });

  factory Session.fromJson(Map<String, dynamic> json) =>
      _$SessionFromJson(json);

  final String id;
  final String roomId;
  final String title;
  final int eventDay;
  final String startTime;
  final String endTime;
  final String? description;
  final String? source;
  final String? sourceSessionId;
  final String? createdAt;
  final String? updatedAt;

  Map<String, dynamic> toJson() => _$SessionToJson(this);

  @override
  List<Object?> get props => [
    id,
    roomId,
    title,
    eventDay,
    startTime,
    endTime,
    description,
    source,
    sourceSessionId,
    createdAt,
    updatedAt,
  ];
}
