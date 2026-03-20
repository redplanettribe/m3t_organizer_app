import 'package:equatable/equatable.dart';

/// Domain representation of a single attendee check-in for a session.
final class SessionCheckIn extends Equatable {
  const SessionCheckIn({
    required this.id,
    required this.sessionID,
    required this.userID,
    required this.checkedInBy,
    required this.createdAt,
    this.name,
    this.lastName,
    this.email,
  });

  final String id;
  final String sessionID;
  final String userID;
  final String checkedInBy;
  final DateTime createdAt;
  final String? name;
  final String? lastName;
  final String? email;

  @override
  List<Object?> get props => [
    id,
    sessionID,
    userID,
    checkedInBy,
    createdAt,
    name,
    lastName,
    email,
  ];
}
