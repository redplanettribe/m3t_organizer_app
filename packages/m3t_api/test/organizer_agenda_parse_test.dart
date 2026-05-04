import 'package:m3t_api/src/realtime/organizer_agenda_websocket_controller.dart';
import 'package:m3t_api/src/realtime/ws_uri.dart';
import 'package:test/test.dart';

void main() {
  group('parseSessionStatusChangedPayload', () {
    test('parses valid envelope', () {
      final payload = parseSessionStatusChangedPayload(<String, dynamic>{
        'type': 'session.status_changed',
        'topic': 'organizer.agenda.abc',
        'data': <String, dynamic>{
          'event_id': 'e1',
          'session_id': 's1',
          'old_status': 'Scheduled',
          'new_status': 'Live',
          'title': 'Keynote',
          'occurred_at': '2026-05-04T13:00:00Z',
        },
        'ts': '2026-05-04T13:00:00Z',
      });

      expect(payload, isNotNull);
      expect(payload!.sessionId, 's1');
      expect(payload.newStatusRaw, 'Live');
      expect(payload.eventId, 'e1');
      expect(payload.title, 'Keynote');
    });

    test('returns null when data missing', () {
      expect(
        parseSessionStatusChangedPayload(<String, dynamic>{
          'type': 'session.status_changed',
        }),
        isNull,
      );
    });
  });

  group('organizerAgendaWebSocketUri', () {
    test('maps http to ws and appends ticket query', () {
      final u = organizerAgendaWebSocketUri(
        apiBaseUrl: 'http://10.0.2.2:8080',
        ticket: 'abc+def',
      );
      expect(u.scheme, 'ws');
      expect(u.path, '/ws');
      expect(u.queryParameters['ticket'], 'abc+def');
    });

    test('maps https to wss', () {
      final u = organizerAgendaWebSocketUri(
        apiBaseUrl: 'https://api.example.com/v1',
        ticket: 't',
      );
      expect(u.scheme, 'wss');
      expect(u.path, '/v1/ws');
    });
  });
}
