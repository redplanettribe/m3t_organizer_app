import 'dart:async';

import 'package:m3t_api/src/models/organizer_agenda_session_status_payload.dart';
import 'package:m3t_api/src/realtime/ws_frame.dart';
import 'package:m3t_api/src/realtime/ws_multiplexer.dart';

const _sessionStatusChangedType = 'session.status_changed';

/// Multiplexed WS: subscribe organizer agenda topic, status push.
final class OrganizerAgendaWebSocketController {
  OrganizerAgendaWebSocketController({
    required WsMultiplexer multiplexer,
    required this.eventID,
    required this.onSessionStatusChanged,
    this.onError,
  }) : _multiplexer = multiplexer;

  final WsMultiplexer _multiplexer;
  final String eventID;
  final void Function(OrganizerAgendaSessionStatusPayload payload)
  onSessionStatusChanged;
  final void Function(Object error)? onError;

  bool _cancelled = false;
  StreamSubscription<WsFrame>? _subscription;
  late final String _topic = 'organizer.agenda.${eventID.toLowerCase()}';

  /// Subscribes to the agenda topic until [cancel] is called.
  void start() {
    _multiplexer
      ..connect()
      ..subscribe(_topic);
    _subscription = _multiplexer.frames(_topic).listen(
      _handleFrame,
      onError: onError,
    );
  }

  void _handleFrame(WsFrame frame) {
    if (_cancelled) return;
    if (frame.type != _sessionStatusChangedType) return;

    final payload = parseSessionStatusChangedPayload(<String, dynamic>{
      'type': frame.type,
      'topic': frame.topic,
      'data': frame.data,
      'id': frame.id,
      'ts': frame.ts,
    });
    if (payload != null) {
      onSessionStatusChanged(payload);
    }
  }

  void cancel() {
    _cancelled = true;
    _multiplexer.unsubscribe(_topic);
    unawaited(_subscription?.cancel());
    _subscription = null;
  }
}

/// Parses server envelope; returns null if shape invalid.
OrganizerAgendaSessionStatusPayload? parseSessionStatusChangedPayload(
  Map<String, dynamic> envelope,
) {
  final data = envelope['data'];
  if (data is! Map<String, dynamic>) return null;

  final sessionId = data['session_id'] as String?;
  final newStatus = data['new_status'] as String?;
  if (sessionId == null || newStatus == null) return null;

  return OrganizerAgendaSessionStatusPayload(
    sessionId: sessionId,
    newStatusRaw: newStatus,
    eventId: data['event_id'] as String?,
    title: data['title'] as String?,
  );
}
