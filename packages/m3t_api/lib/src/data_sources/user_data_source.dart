import 'dart:convert';

import 'package:m3t_api/src/exceptions.dart';
import 'package:m3t_api/src/http/api_http_executor.dart';
import 'package:m3t_api/src/http/api_paths.dart';
import 'package:m3t_api/src/models/api_error.dart';
import 'package:m3t_api/src/models/user.dart';

/// Handles all user profile and avatar API calls.
final class UserDataSource {
  const UserDataSource({required ApiHttpExecutor executor})
    : _executor = executor;

  final ApiHttpExecutor _executor;

  Future<User> getCurrentUser() async {
    final response = await _executor.client.get(
      _executor.uri(UserPaths.me),
      headers: await _executor.authHeaders(),
    );

    if (response.statusCode != 200) {
      throw GetCurrentUserFailure(
        'Request failed with status ${response.statusCode}',
      );
    }

    final body = _executor.decodeJson(response.body);
    final errorJson = body['error'] as Map<String, dynamic>?;
    if (errorJson != null) {
      final error = ApiError.fromJson(errorJson);
      throw GetCurrentUserFailure(error.message);
    }

    final dataJson = body['data'] as Map<String, dynamic>?;
    if (dataJson == null) {
      throw GetCurrentUserFailure('Missing data field in response');
    }

    return User.fromJson(dataJson);
  }

  Future<void> deleteCurrentUser() async {
    final response = await _executor.client.delete(
      _executor.uri(UserPaths.me),
      headers: await _executor.authHeaders(),
    );

    if (response.statusCode != 200) {
      throw DeleteCurrentUserFailure(
        'Request failed with status ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }

    final body = _executor.decodeJson(response.body);
    final errorJson = body['error'] as Map<String, dynamic>?;
    if (errorJson != null) {
      final error = ApiError.fromJson(errorJson);
      throw DeleteCurrentUserFailure(
        error.message,
        statusCode: response.statusCode,
        errorCode: error.code,
      );
    }
  }

  Future<User> updateCurrentUser({
    String? name,
    String? lastName,
  }) async {
    if (name == null && lastName == null) {
      throw ArgumentError(
        'At least one of name or lastName must be provided.',
      );
    }

    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (lastName != null) body['last_name'] = lastName;

    final response = await _executor.client.patch(
      _executor.uri(UserPaths.me),
      headers: await _executor.authHeaders(),
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw UpdateCurrentUserFailure(
        'Request failed with status ${response.statusCode}',
      );
    }

    final bodyJson = _executor.decodeJson(response.body);
    final errorJson = bodyJson['error'] as Map<String, dynamic>?;
    if (errorJson != null) {
      final error = ApiError.fromJson(errorJson);
      throw UpdateCurrentUserFailure(error.message);
    }

    final dataJson = bodyJson['data'] as Map<String, dynamic>?;
    if (dataJson == null) {
      throw UpdateCurrentUserFailure('Missing data field in response');
    }

    return User.fromJson(dataJson);
  }

  Future<(Uri uploadUrl, String key)> requestAvatarUploadUrl() async {
    final response = await _executor.client.post(
      _executor.uri(UserPaths.avatarUploadUrl),
      headers: await _executor.authHeaders(),
    );

    if (response.statusCode != 200) {
      throw RequestAvatarUploadFailure(
        'Avatar upload URL request failed with status ${response.statusCode}',
      );
    }

    final dynamic decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw RequestAvatarUploadFailure('Expected JSON object response');
    }

    final root = decoded;

    // Some endpoints wrap responses in a { data, error } envelope.
    final Map<String, dynamic>? data;
    if (root.containsKey('key') && root.containsKey('upload_url')) {
      data = root;
    } else {
      final nested = root['data'];
      data = nested is Map<String, dynamic> ? nested : null;
    }

    final key = data?['key'] as String?;
    final uploadUrl = data?['upload_url'] as String?;

    if (key == null || uploadUrl == null) {
      throw RequestAvatarUploadFailure('Missing key or upload_url in response');
    }

    return (Uri.parse(uploadUrl), key);
  }

  Future<void> uploadAvatarBytes({
    required Uri uploadUrl,
    required List<int> bytes,
    required String contentType,
  }) async {
    final objectStoreBaseUrl = _executor.objectStoreBaseUrl;
    // Only rewrite to [objectStoreBaseUrl] (e.g. 10.0.2.2 for Android emulator)
    // when the API signed a loopback URL. Production/R2 URLs must be used as-is
    // on physical devices and in release builds.
    final Uri effectiveUploadUrl;
    final bool rewriteForReachability;
    if (objectStoreBaseUrl != null &&
        _presignedUrlHostNeedsObjectStoreRewrite(uploadUrl.host)) {
      rewriteForReachability = true;
      effectiveUploadUrl = uploadUrl.replace(
        scheme: objectStoreBaseUrl.scheme,
        host: objectStoreBaseUrl.host,
        port: objectStoreBaseUrl.hasPort ? objectStoreBaseUrl.port : null,
      );
    } else {
      rewriteForReachability = false;
      effectiveUploadUrl = uploadUrl;
    }
    final signedHost = uploadUrl.hasPort
        ? '${uploadUrl.host}:${uploadUrl.port}'
        : uploadUrl.host;

    final headers = <String, String>{'content-type': contentType};
    if (rewriteForReachability) {
      // Presigned S3 URLs include `host` in signed headers; keep the signed
      // value while connecting via the emulator-reachable address.
      headers['host'] = signedHost;
    }

    final response = await _executor.client.put(
      effectiveUploadUrl,
      headers: headers,
      body: bytes,
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw UploadAvatarFailure(
        'Avatar upload failed with status ${response.statusCode}',
      );
    }
  }

  Future<User> confirmAvatar({required String key}) async {
    final response = await _executor.client.put(
      _executor.uri(UserPaths.avatar),
      headers: await _executor.authHeaders(),
      body: jsonEncode(<String, String>{'key': key}),
    );

    if (response.statusCode != 200) {
      throw ConfirmAvatarFailure(
        'Confirm avatar failed with status ${response.statusCode}',
      );
    }

    final bodyJson = _executor.decodeJson(response.body);
    final errorJson = bodyJson['error'] as Map<String, dynamic>?;
    if (errorJson != null) {
      final error = ApiError.fromJson(errorJson);
      throw ConfirmAvatarFailure(error.message);
    }

    final dataJson = bodyJson['data'] as Map<String, dynamic>?;
    if (dataJson == null) {
      throw ConfirmAvatarFailure('Missing data field in response');
    }

    return User.fromJson(dataJson);
  }
}

/// True when the presigned URL targets the machine running MinIO/S3 locally.
/// In that case the Android emulator replaces the host with the object-store
/// base URL (typically `10.0.2.2`). Remote hosts (R2, AWS S3, etc.) are never
/// rewritten.
bool _presignedUrlHostNeedsObjectStoreRewrite(String host) {
  final h = host.toLowerCase();
  return h == 'localhost' || h == '127.0.0.1' || h == '::1';
}
