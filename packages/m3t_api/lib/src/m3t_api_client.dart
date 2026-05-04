import 'package:http/http.dart' as http;
import 'package:m3t_api/src/data_sources/auth_data_source.dart';
import 'package:m3t_api/src/data_sources/events_data_source.dart';
import 'package:m3t_api/src/data_sources/sessions_data_source.dart';
import 'package:m3t_api/src/data_sources/user_data_source.dart';
import 'package:m3t_api/src/http/api_http_executor.dart';
import 'package:m3t_api/src/models/agenda_ws_ticket.dart';
import 'package:m3t_api/src/models/deliverable_giveaway.dart';
import 'package:m3t_api/src/models/event.dart';
import 'package:m3t_api/src/models/event_check_in.dart';
import 'package:m3t_api/src/models/event_deliverable.dart';
import 'package:m3t_api/src/models/get_event_by_id_response.dart';
import 'package:m3t_api/src/models/login_response.dart';
import 'package:m3t_api/src/models/session.dart';
import 'package:m3t_api/src/models/session_check_in.dart';
import 'package:m3t_api/src/models/user.dart';

/// Signature for a callback that returns the stored auth token (or null).
typedef TokenProvider = Future<String?> Function();

/// Facade that delegates every API call to a typed per-domain data source.
///
/// Call sites are unchanged — all method signatures are preserved exactly.
/// Infrastructure (HTTP client, base URL, token provider) is shared via
/// [ApiHttpExecutor] and injected into each data source at construction time.
class M3tApiClient {
  M3tApiClient({
    http.Client? httpClient,
    String? baseUrl,
    Uri? objectStoreBaseUrl,
    TokenProvider? tokenProvider,
  }) : _baseUrl = baseUrl ?? 'http://10.0.2.2:8080' {
    final executor = ApiHttpExecutor(
      httpClient: httpClient ?? http.Client(),
      baseUrl: _baseUrl,
      objectStoreBaseUrl: objectStoreBaseUrl,
      tokenProvider: tokenProvider,
    );
    _auth = AuthDataSource(executor: executor);
    _user = UserDataSource(executor: executor);
    _events = EventsDataSource(executor: executor);
    _sessions = SessionsDataSource(executor: executor);
  }

  /// REST API root (same host/scheme as WebSocket, different path).
  String get baseUrl => _baseUrl;

  final String _baseUrl;

  late final AuthDataSource _auth;
  late final UserDataSource _user;
  late final EventsDataSource _events;
  late final SessionsDataSource _sessions;

  // ── Auth ─────────────────────────────────────────────────────────────────

  Future<void> requestLoginCode(String email) => _auth.requestLoginCode(email);

  Future<LoginResponse> verifyLoginCode({
    required String email,
    required String code,
  }) => _auth.verifyLoginCode(email: email, code: code);

  // ── User ─────────────────────────────────────────────────────────────────

  Future<User> getCurrentUser() => _user.getCurrentUser();

  Future<void> deleteCurrentUser() => _user.deleteCurrentUser();

  Future<User> updateCurrentUser({String? name, String? lastName}) =>
      _user.updateCurrentUser(name: name, lastName: lastName);

  Future<(Uri uploadUrl, String key)> requestAvatarUploadUrl() =>
      _user.requestAvatarUploadUrl();

  Future<void> uploadAvatarBytes({
    required Uri uploadUrl,
    required List<int> bytes,
    required String contentType,
  }) => _user.uploadAvatarBytes(
    uploadUrl: uploadUrl,
    bytes: bytes,
    contentType: contentType,
  );

  Future<User> confirmAvatar({required String key}) =>
      _user.confirmAvatar(key: key);

  // ── Events ─────────────────────────────────────────────────────────────

  Future<List<Event>> getMyEvents() => _events.getMyEvents();

  Future<GetEventByIdResponse> getEventById({
    required String eventID,
  }) => _events.getEventById(eventID: eventID);

  Future<({EventCheckIn checkIn, bool alreadyCheckedIn})> checkInAttendee({
    required String eventID,
    required String userID,
  }) => _events.checkInAttendee(eventID: eventID, userID: userID);

  Future<List<EventDeliverable>> getEventDeliverables({
    required String eventID,
  }) => _events.getEventDeliverables(eventID: eventID);

  Future<DeliverableGiveaway> giveDeliverableToUser({
    required String eventID,
    required String deliverableID,
    required String userID,
    bool giveAnyway = false,
  }) => _events.giveDeliverableToUser(
    eventID: eventID,
    deliverableID: deliverableID,
    userID: userID,
    giveAnyway: giveAnyway,
  );

  Future<({SessionCheckIn checkIn, bool alreadyCheckedIn})>
  checkInAttendeeToSession({
    required String eventID,
    required String sessionID,
    required String userID,
  }) => _events.checkInAttendeeToSession(
    eventID: eventID,
    sessionID: sessionID,
    userID: userID,
  );

  Future<int> releaseUncheckedInSessionBookings({
    required String eventID,
    required String sessionID,
  }) =>
      _events.releaseUncheckedInSessionBookings(
        eventID: eventID,
        sessionID: sessionID,
      );

  Future<AgendaWsTicket> getOrganizerAgendaWebSocketTicket({
    required String eventID,
  }) => _events.getOrganizerAgendaWebSocketTicket(eventID: eventID);

  // ── Sessions ─────────────────────────────────────────────────────────────

  Future<Session> getSessionById({required String sessionID}) =>
      _sessions.getSessionById(sessionID: sessionID);

  Future<Session> updateSessionStatus({
    required String eventID,
    required String sessionID,
    required String status,
  }) => _sessions.updateSessionStatus(
    eventID: eventID,
    sessionID: sessionID,
    status: status,
  );
}
