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

  static String deliverables(String eventID) =>
      '/events/$eventID/deliverables';

  static String deliverableGiveaways({
    required String eventID,
    required String deliverableID,
  }) =>
      '/events/$eventID/deliverables/$deliverableID/giveaways';

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
  }) =>
      '/events/$eventID/sessions/$sessionID/bookings';

  static String updateStatus({
    required String eventID,
    required String sessionID,
  }) => '/events/$eventID/sessions/$sessionID/status';
}
