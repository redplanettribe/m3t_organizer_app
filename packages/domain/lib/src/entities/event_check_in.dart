import 'package:equatable/equatable.dart';

/// Domain representation of a single attendee check-in for an event.
final class EventCheckIn extends Equatable {
  const EventCheckIn({
    required this.id,
    required this.eventID,
    required this.userID,
    required this.checkedInBy,
    required this.createdAt,
    this.name,
    this.lastName,
    this.email,
  });

  final String id;
  final String eventID;
  final String userID;
  final String checkedInBy;
  final String? name;
  final String? lastName;
  final String? email;
  final DateTime createdAt;

  @override
  List<Object?> get props => [
    id,
    eventID,
    userID,
    checkedInBy,
    name,
    lastName,
    email,
    createdAt,
  ];
}
