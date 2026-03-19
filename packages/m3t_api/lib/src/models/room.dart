import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'room.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
final class Room extends Equatable {
  const Room({
    required this.id,
    required this.eventId,
    required this.name,
    required this.capacity,
    required this.notBookable,
    this.description,
    this.howToGetThere,
    this.source,
    this.sourceSessionId,
    this.createdAt,
    this.updatedAt,
  });

  factory Room.fromJson(Map<String, dynamic> json) => _$RoomFromJson(json);

  final String id;
  final String eventId;
  final String name;
  final int capacity;
  final String? description;
  final String? howToGetThere;
  final bool notBookable;
  final String? source;
  final int? sourceSessionId;
  final String? createdAt;
  final String? updatedAt;

  Map<String, dynamic> toJson() => _$RoomToJson(this);

  @override
  List<Object?> get props => [
    id,
    eventId,
    name,
    capacity,
    description,
    howToGetThere,
    notBookable,
    source,
    sourceSessionId,
    createdAt,
    updatedAt,
  ];
}
