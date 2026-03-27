import 'package:equatable/equatable.dart';

/// A deliverable that can be given to attendees at an event.
final class EventDeliverable extends Equatable {
  const EventDeliverable({
    required this.id,
    required this.name,
    this.description,
  });

  final String id;
  final String name;
  final String? description;

  @override
  List<Object?> get props => [id, name, description];
}
