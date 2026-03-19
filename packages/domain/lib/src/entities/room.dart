import 'package:equatable/equatable.dart';

/// Domain representation of an event room.
final class Room extends Equatable {
  const Room({
    required this.id,
    required this.eventID,
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

  final String id;
  final String eventID;
  final String name;
  final int capacity;
  final String? description;
  final String? howToGetThere;
  final bool notBookable;
  final String? source;
  final int? sourceSessionId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  @override
  List<Object?> get props => [
    id,
    eventID,
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
