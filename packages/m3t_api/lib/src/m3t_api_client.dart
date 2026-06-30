import 'package:http/http.dart' as http;
import 'package:m3t_api/src/data_sources/auth_data_source.dart';
import 'package:m3t_api/src/data_sources/chat_data_source.dart';
import 'package:m3t_api/src/data_sources/events_data_source.dart';
import 'package:m3t_api/src/data_sources/remote_config_data_source.dart';
import 'package:m3t_api/src/data_sources/sessions_data_source.dart';
import 'package:m3t_api/src/data_sources/user_data_source.dart';
import 'package:m3t_api/src/http/api_http_executor.dart';
import 'package:m3t_api/src/models/agenda_ws_ticket.dart';
import 'package:m3t_api/src/models/chat_ban.dart';
import 'package:m3t_api/src/models/chat_ban_page.dart';
import 'package:m3t_api/src/models/chat_conversation_page.dart';
import 'package:m3t_api/src/models/chat_message.dart';
import 'package:m3t_api/src/models/chat_message_page.dart';
import 'package:m3t_api/src/models/chat_message_reactions.dart';
import 'package:m3t_api/src/models/deliverable_giveaway.dart';
import 'package:m3t_api/src/models/event.dart';
import 'package:m3t_api/src/models/event_check_in.dart';
import 'package:m3t_api/src/models/event_deliverable.dart';
import 'package:m3t_api/src/models/event_registration_page.dart';
import 'package:m3t_api/src/models/get_event_by_id_response.dart';
import 'package:m3t_api/src/models/login_response.dart';
import 'package:m3t_api/src/models/mobile_remote_config_response.dart';
import 'package:m3t_api/src/models/send_chat_message_request.dart';
import 'package:m3t_api/src/models/session.dart';
import 'package:m3t_api/src/models/session_check_in.dart';
import 'package:m3t_api/src/models/user.dart';
import 'package:m3t_api/src/realtime/ws_multiplexer.dart';

/// Signature for a callback that returns the stored auth token (or null).
typedef TokenProvider = Future<String?> Function();

/// Invoked when the backend returns `error.code: invalid_or_expired_token`.
typedef SessionExpiredCallback = void Function();

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
    SessionExpiredCallback? onSessionExpired,
  }) : _baseUrl = baseUrl ?? 'http://10.0.2.2:8080',
       _tokenProvider = tokenProvider ?? (() async => null) {
    final executor = ApiHttpExecutor(
      httpClient: httpClient ?? http.Client(),
      baseUrl: _baseUrl,
      objectStoreBaseUrl: objectStoreBaseUrl,
      tokenProvider: tokenProvider,
      onSessionExpired: onSessionExpired,
    );
    _auth = AuthDataSource(executor: executor);
    _user = UserDataSource(executor: executor);
    _events = EventsDataSource(executor: executor);
    _sessions = SessionsDataSource(executor: executor);
    _remoteConfig = RemoteConfigDataSource(executor: executor);
    _chat = ChatDataSource(executor: executor);
  }

  /// REST API root (same host/scheme as WebSocket, different path).
  String get baseUrl => _baseUrl;

  final String _baseUrl;
  final TokenProvider _tokenProvider;
  WsMultiplexer? _wsMultiplexer;

  late final AuthDataSource _auth;
  late final UserDataSource _user;
  late final EventsDataSource _events;
  late final SessionsDataSource _sessions;
  late final RemoteConfigDataSource _remoteConfig;
  late final ChatDataSource _chat;

  ChatDataSource get chat => _chat;

  /// Shared multiplexed WebSocket for agenda, chat, and other topics.
  WsMultiplexer get wsMultiplexer {
    return _wsMultiplexer ??= WsMultiplexer(
      apiBaseUrl: _baseUrl,
      tokenProvider: _tokenProvider,
    )..connect();
  }

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

  Future<EventRegistrationPage> listEventRegistrations({
    required String eventID,
    String? search,
    int? page,
    int? pageSize,
  }) => _events.listEventRegistrations(
    eventID: eventID,
    search: search,
    page: page,
    pageSize: pageSize,
  );

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
    bool overrideCapacity = false,
  }) => _events.checkInAttendeeToSession(
    eventID: eventID,
    sessionID: sessionID,
    userID: userID,
    overrideCapacity: overrideCapacity,
  );

  Future<int> releaseUncheckedInSessionBookings({
    required String eventID,
    required String sessionID,
  }) => _events.releaseUncheckedInSessionBookings(
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

  // ── Mobile ────────────────────────────────────────────────────────────────

  Future<MobileRemoteConfigResponse> getMobileRemoteConfig({
    required String app,
    required String platform,
  }) => _remoteConfig.getMobileRemoteConfig(app: app, platform: platform);

  // ── Chat ─────────────────────────────────────────────────────────────────

  Future<ChatMessagePage> getGeneralChatMessages({
    required String eventID,
    int? limit,
    String? cursor,
  }) => _chat.getGeneralMessages(
    eventID: eventID,
    limit: limit,
    cursor: cursor,
  );

  Future<ChatMessage> sendGeneralChatMessage({
    required String eventID,
    required String body,
    String? clientMsgId,
    String? replyToMessageId,
  }) => _chat.sendGeneralMessage(
    eventID: eventID,
    body: body,
    clientMsgId: clientMsgId,
    replyToMessageId: replyToMessageId,
  );

  Future<void> deleteAttendeeChatMessage({
    required String eventID,
    required String messageID,
  }) => _chat.deleteAttendeeMessage(eventID: eventID, messageID: messageID);

  Future<ChatMessageReactions> setChatMessageReaction({
    required String eventID,
    required String messageID,
    required String emoji,
  }) => _chat.setMessageReaction(
    eventID: eventID,
    messageID: messageID,
    emoji: emoji,
  );

  Future<ChatMessageReactions> removeChatMessageReaction({
    required String eventID,
    required String messageID,
  }) => _chat.removeMessageReaction(eventID: eventID, messageID: messageID);

  Future<ChatConversationPage> getDmConversations({
    required String eventID,
    int? limit,
    String? cursor,
  }) => _chat.getDmConversations(
    eventID: eventID,
    limit: limit,
    cursor: cursor,
  );

  Future<ChatMessagePage> getDmMessages({
    required String eventID,
    required String recipientUserID,
    int? limit,
    String? cursor,
  }) => _chat.getDmMessages(
    eventID: eventID,
    recipientUserID: recipientUserID,
    limit: limit,
    cursor: cursor,
  );

  Future<ChatMessage> sendDmMessage({
    required String eventID,
    required String recipientUserID,
    required String body,
    String? clientMsgId,
    String? replyToMessageId,
  }) => _chat.sendDmMessage(
    eventID: eventID,
    recipientUserID: recipientUserID,
    request: SendChatMessageRequest(
      body: body,
      clientMsgId: clientMsgId,
      replyToMessageId: replyToMessageId,
    ),
  );

  Future<ChatMessagePage> getOrganizerChatMessages({
    required String eventID,
    String? cursor,
    int? limit,
  }) => _chat.getOrganizerMessages(
    eventID: eventID,
    cursor: cursor,
    limit: limit,
  );

  Future<ChatMessage> sendOrganizerChatMessage({
    required String eventID,
    required String body,
    String? clientMsgId,
    String? replyToMessageId,
  }) => _chat.sendOrganizerMessage(
    eventID: eventID,
    request: SendChatMessageRequest(
      body: body,
      clientMsgId: clientMsgId,
      replyToMessageId: replyToMessageId,
    ),
  );

  Future<void> deleteOrganizerChatMessage({
    required String eventID,
    required String messageID,
  }) => _chat.deleteOrganizerMessage(eventID: eventID, messageID: messageID);

  Future<ChatMessageReactions> setOrganizerChatReaction({
    required String eventID,
    required String messageID,
    required String emoji,
  }) => _chat.setOrganizerMessageReaction(
    eventID: eventID,
    messageID: messageID,
    emoji: emoji,
  );

  Future<ChatMessageReactions> removeOrganizerChatReaction({
    required String eventID,
    required String messageID,
  }) => _chat.removeOrganizerMessageReaction(
    eventID: eventID,
    messageID: messageID,
  );

  Future<void> deleteGeneralChatMessageAsOrganizer({
    required String eventID,
    required String messageID,
  }) => _chat.deleteGeneralMessageAsOrganizer(
    eventID: eventID,
    messageID: messageID,
  );

  Future<ChatBan> banChatUser({
    required String eventID,
    required String userID,
  }) => _chat.banChatUser(eventID: eventID, userID: userID);

  Future<void> unbanChatUser({
    required String eventID,
    required String userID,
  }) => _chat.unbanChatUser(eventID: eventID, userID: userID);

  Future<ChatBanPage> listChatBans({
    required String eventID,
    int? page,
    int? pageSize,
  }) => _chat.listChatBans(eventID: eventID, page: page, pageSize: pageSize);
}
