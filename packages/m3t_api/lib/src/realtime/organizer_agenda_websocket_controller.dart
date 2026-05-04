import 'dart:async';
import 'dart:convert';

import 'package:m3t_api/src/models/agenda_ws_ticket.dart';
import 'package:m3t_api/src/models/organizer_agenda_session_status_payload.dart';
import 'package:m3t_api/src/realtime/ws_uri.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

const _sessionStatusChangedType = 'session.status_changed';

/// Multiplexed WS: ticket auth, subscribe organizer agenda topic, status push.
final class OrganizerAgendaWebSocketController {
  OrganizerAgendaWebSocketController({
    required this.apiBaseUrl,
    required this.eventID,
    required this.getTicket,
    required this.onSessionStatusChanged,
    this.onError,
  });

  final String apiBaseUrl;
  final String eventID;
  final Future<AgendaWsTicket> Function() getTicket;
  final void Function(OrganizerAgendaSessionStatusPayload payload)
  onSessionStatusChanged;
  final void Function(Object error)? onError;

  bool _cancelled = false;
  WebSocketChannel? _channel;
  static const _initialReconnectDelay = Duration(seconds: 1);
  static const _maxReconnectDelay = Duration(seconds: 30);

  /// Starts reconnect loop until [cancel] is called.
  void start() {
    unawaited(_runLoop());
  }

  Future<void> _runLoop() async {
    var delay = _initialReconnectDelay;
    while (!_cancelled) {
      try {
        final ticketRow = await getTicket();
        if (_cancelled) return;

        final uri = organizerAgendaWebSocketUri(
          apiBaseUrl: apiBaseUrl,
          ticket: ticketRow.ticket,
        );
        final channel = WebSocketChannel.connect(uri);
        _channel = channel;
        delay = _initialReconnectDelay;

        _sendSubscribe(channel);

        await for (final message in channel.stream) {
          if (_cancelled) break;
          _handleRawMessage(message);
        }
      } on Object catch (e, _) {
        if (_cancelled) return;
        onError?.call(e);
      } finally {
        await _channel?.sink.close();
        _channel = null;
      }

      if (_cancelled) return;
      await Future<void>.delayed(delay);
      final nextMs = (delay.inMilliseconds * 2).clamp(
        _initialReconnectDelay.inMilliseconds,
        _maxReconnectDelay.inMilliseconds,
      );
      delay = Duration(milliseconds: nextMs);
    }
  }

  void _sendSubscribe(WebSocketChannel channel) {
    final topic = 'organizer.agenda.${eventID.toLowerCase()}';
    final frame = jsonEncode(<String, dynamic>{
      'type': 'subscribe',
      'topic': topic,
      'id': 'sub-${DateTime.now().microsecondsSinceEpoch}',
    });
    channel.sink.add(frame);
  }

  void _handleRawMessage(dynamic message) {
    final text = switch (message) {
      final String s => s,
      final List<int> bytes => utf8.decode(bytes),
      _ => message.toString(),
    };

    try {
      final decoded = jsonDecode(text);
      if (decoded is! Map<String, dynamic>) return;

      final type = decoded['type'] as String?;
      if (type == 'pong') return;

      if (type == 'error') {
        final data = decoded['data'];
        if (data is Map<String, dynamic>) {
          onError?.call(
            StateError(
              '${data['code']}: ${data['message']}',
            ),
          );
        } else {
          onError?.call(StateError('websocket error frame'));
        }
        return;
      }

      if (type == _sessionStatusChangedType) {
        final payload = parseSessionStatusChangedPayload(decoded);
        if (payload != null) {
          onSessionStatusChanged(payload);
        }
      }
    } on Object catch (e) {
      onError?.call(e);
    }
  }

  void cancel() {
    _cancelled = true;
    unawaited(_channel?.sink.close() ?? Future<void>.value());
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
