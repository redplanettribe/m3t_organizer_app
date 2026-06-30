import 'package:equatable/equatable.dart';

/// A registered attendee for an event (organizer list view).
final class EventRegistration extends Equatable {
  const EventRegistration({
    required this.registrationId,
    required this.eventId,
    required this.userId,
    this.name,
    this.lastName,
    this.email,
    this.checkedIn,
    this.tierName,
  });

  final String registrationId;
  final String eventId;
  final String userId;
  final String? name;
  final String? lastName;
  final String? email;
  final bool? checkedIn;
  final String? tierName;

  String get displayName {
    final full = [
      name,
      lastName,
    ].whereType<String>().where((s) => s.trim().isNotEmpty).join(' ');
    return full.isNotEmpty ? full : userId;
  }

  @override
  List<Object?> get props => [
    registrationId,
    eventId,
    userId,
    name,
    lastName,
    email,
    checkedIn,
    tierName,
  ];
}

/// Page-based list of event registrations.
final class EventRegistrationPage extends Equatable {
  const EventRegistrationPage({
    required this.items,
    this.page,
    this.pageSize,
    this.total,
    this.totalPages,
  });

  final List<EventRegistration> items;
  final int? page;
  final int? pageSize;
  final int? total;
  final int? totalPages;

  @override
  List<Object?> get props => [items, page, pageSize, total, totalPages];
}
