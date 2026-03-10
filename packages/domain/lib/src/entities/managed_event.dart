import 'package:equatable/equatable.dart';

/// Domain entity for an event the current user manages (owner or team member).
final class ManagedEventEntity extends Equatable {
  const ManagedEventEntity({
    required this.eventId,
    required this.name,
    this.description,
    this.eventCode,
    this.startDate,
    this.durationDays,
    this.thumbnailUrl,
  });

  final String eventId;
  final String name;
  final String? description;
  final String? eventCode;
  final String? startDate;
  final int? durationDays;
  final String? thumbnailUrl;

  @override
  List<Object?> get props => [
        eventId,
        name,
        description,
        eventCode,
        startDate,
        durationDays,
        thumbnailUrl,
      ];
}
