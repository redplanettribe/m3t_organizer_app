abstract final class AuthPaths {
  static const requestLoginCode = '/auth/login/request';
  static const verifyLoginCode = '/auth/login/verify';
}

abstract final class UserPaths {
  static const me = '/users/me';
  static const avatarUploadUrl = '/users/me/avatar/upload-url';
  static const avatar = '/users/me/avatar';
}

abstract final class EventPaths {
  static const me = '/events/me';

  static String byId(String eventID) => '/events/$eventID';

  static String checkIns(String eventID) => '/events/$eventID/check-ins';

  static String deliverables(String eventID) => '/events/$eventID/deliverables';

  static String registrations(String eventID) =>
      '/events/$eventID/registrations';

  static String deliverableGiveaways({
    required String eventID,
    required String deliverableID,
  }) => '/events/$eventID/deliverables/$deliverableID/giveaways';

  static String agendaWebSocketTicket(String eventID) =>
      '/events/$eventID/agenda/ws/ticket';
}

abstract final class SessionPaths {
  static String byId(String sessionID) => '/sessions/$sessionID';

  static String checkIns({
    required String eventID,
    required String sessionID,
  }) => '/events/$eventID/sessions/$sessionID/check-ins';

  static String releaseUncheckedInSessionBookings({
    required String eventID,
    required String sessionID,
  }) => '/events/$eventID/sessions/$sessionID/bookings';

  static String updateStatus({
    required String eventID,
    required String sessionID,
  }) => '/events/$eventID/sessions/$sessionID/status';
}

abstract final class MobilePaths {
  static const remoteConfig = '/mobile/remote-config';
}

abstract final class ChatPaths {
  static String generalMessages(String eventID) =>
      '/attendee/events/$eventID/chat/general/messages';

  static String dmMessages({
    required String eventID,
    required String recipientUserID,
  }) => '/attendee/events/$eventID/chat/dm/$recipientUserID/messages';

  static String dmConversations(String eventID) =>
      '/attendee/events/$eventID/chat/dm/conversations';

  static String attendeeMessage({
    required String eventID,
    required String messageID,
  }) => '/attendee/events/$eventID/chat/messages/$messageID';

  static String attendeeMessageReactions({
    required String eventID,
    required String messageID,
  }) => '/attendee/events/$eventID/chat/messages/$messageID/reactions';

  static String organizerMessages(String eventID) =>
      '/events/$eventID/chat/organizers/messages';

  static String organizerMessage({
    required String eventID,
    required String messageID,
  }) => '/events/$eventID/chat/organizers/messages/$messageID';

  static String organizerMessageReactions({
    required String eventID,
    required String messageID,
  }) => '/events/$eventID/chat/organizers/messages/$messageID/reactions';

  static String organizerDeleteGeneralMessage({
    required String eventID,
    required String messageID,
  }) => '/events/$eventID/chat/messages/$messageID';

  static String chatBans(String eventID) => '/events/$eventID/chat/bans';

  static String chatBan({
    required String eventID,
    required String userID,
  }) => '/events/$eventID/chat/bans/$userID';
}
