import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import 'package:m3t_api/src/models/speaker.dart';
import 'package:m3t_api/src/models/tag.dart';

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
    this.status,
    this.speakers,
    this.tags,
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
  final String? status;
  final List<Speaker>? speakers;
  final List<Tag>? tags;
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
    status,
    speakers,
    tags,
    createdAt,
    updatedAt,
  ];
}
