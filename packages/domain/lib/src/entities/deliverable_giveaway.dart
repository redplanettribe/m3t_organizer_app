import 'package:equatable/equatable.dart';

/// Record of giving a deliverable to a user at an event.
final class DeliverableGiveaway extends Equatable {
  const DeliverableGiveaway({
    required this.id,
    required this.eventID,
    required this.deliverableID,
    required this.userID,
    required this.givenBy,
    required this.createdAt,
    this.name,
    this.lastName,
    this.email,
    this.deliverableName,
  });

  final String id;
  final String eventID;
  final String deliverableID;
  final String userID;
  final String givenBy;
  final String? name;
  final String? lastName;
  final String? email;
  final String? deliverableName;
  final DateTime createdAt;

  @override
  List<Object?> get props => [
    id,
    eventID,
    deliverableID,
    userID,
    givenBy,
    name,
    lastName,
    email,
    deliverableName,
    createdAt,
  ];
}
