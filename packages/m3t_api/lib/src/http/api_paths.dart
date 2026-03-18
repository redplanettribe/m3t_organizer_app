abstract final class AuthPaths {
  static const requestLoginCode = '/auth/login/request';
  static const verifyLoginCode = '/auth/login/verify';
}

abstract final class UserPaths {
  static const me = '/users/me';
  static const avatarUploadUrl = '/users/me/avatar/upload-url';
  static const avatar = '/users/me/avatar';
}
