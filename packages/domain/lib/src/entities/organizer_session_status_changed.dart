import 'package:domain/src/enums/session_status.dart';
import 'package:equatable/equatable.dart';

/// Payload from organizer agenda WebSocket `session.status_changed`.
final class OrganizerSessionStatusChanged extends Equatable {
  const OrganizerSessionStatusChanged({
    required this.sessionId,
    required this.newStatus,
    this.eventId,
    this.title,
  });

  final String sessionId;
  final SessionStatus newStatus;

  /// Present when the server includes it; optional for future asserts.
  final String? eventId;

  /// Session title from realtime payload when present.
  final String? title;

  @override
  List<Object?> get props => [sessionId, newStatus, eventId, title];
}
