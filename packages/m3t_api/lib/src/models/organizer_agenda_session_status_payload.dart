import 'package:equatable/equatable.dart';

/// Parsed `data` from WebSocket `session.status_changed` frame.
final class OrganizerAgendaSessionStatusPayload extends Equatable {
  const OrganizerAgendaSessionStatusPayload({
    required this.sessionId,
    required this.newStatusRaw,
    this.eventId,
    this.title,
  });

  final String sessionId;
  final String newStatusRaw;
  final String? eventId;
  final String? title;

  @override
  List<Object?> get props => [sessionId, newStatusRaw, eventId, title];
}
