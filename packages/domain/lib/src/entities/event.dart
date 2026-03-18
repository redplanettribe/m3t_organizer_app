import 'package:equatable/equatable.dart';

/// Domain representation of an organizer-managed event.
final class Event extends Equatable {
  const Event({
    required this.id,
    required this.name,
    this.startDate,
    this.durationDays,
    this.description,
    this.eventCode,
    this.locationLat,
    this.locationLng,
    this.ownerId,
    this.thumbnailUrl,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final DateTime? startDate;
  final int? durationDays;
  final String? description;
  final String? eventCode;
  final double? locationLat;
  final double? locationLng;
  final String? ownerId;
  final String? thumbnailUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Event copyWith({
    String? id,
    String? name,
    Object? startDate = _sentinel,
    Object? durationDays = _sentinel,
    Object? description = _sentinel,
    Object? eventCode = _sentinel,
    Object? locationLat = _sentinel,
    Object? locationLng = _sentinel,
    Object? ownerId = _sentinel,
    Object? thumbnailUrl = _sentinel,
    Object? createdAt = _sentinel,
    Object? updatedAt = _sentinel,
  }) {
    return Event(
      id: id ?? this.id,
      name: name ?? this.name,
      startDate: startDate == _sentinel
          ? this.startDate
          : startDate as DateTime?,
      durationDays: durationDays == _sentinel
          ? this.durationDays
          : durationDays as int?,
      description: description == _sentinel
          ? this.description
          : description as String?,
      eventCode: eventCode == _sentinel ? this.eventCode : eventCode as String?,
      locationLat: locationLat == _sentinel
          ? this.locationLat
          : locationLat as double?,
      locationLng: locationLng == _sentinel
          ? this.locationLng
          : locationLng as double?,
      ownerId: ownerId == _sentinel ? this.ownerId : ownerId as String?,
      thumbnailUrl: thumbnailUrl == _sentinel
          ? this.thumbnailUrl
          : thumbnailUrl as String?,
      createdAt: createdAt == _sentinel
          ? this.createdAt
          : createdAt as DateTime?,
      updatedAt: updatedAt == _sentinel
          ? this.updatedAt
          : updatedAt as DateTime?,
    );
  }

  static const _sentinel = Object();

  @override
  List<Object?> get props => [
    id,
    name,
    startDate,
    durationDays,
    description,
    eventCode,
    locationLat,
    locationLng,
    ownerId,
    thumbnailUrl,
    createdAt,
    updatedAt,
  ];
}

//
