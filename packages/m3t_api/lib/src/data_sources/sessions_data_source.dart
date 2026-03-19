import 'dart:convert';

import 'package:m3t_api/src/exceptions.dart';
import 'package:m3t_api/src/http/api_http_executor.dart';
import 'package:m3t_api/src/http/api_paths.dart';
import 'package:m3t_api/src/models/api_error.dart';
import 'package:m3t_api/src/models/session.dart';

/// Handles session-related API calls.
final class SessionsDataSource {
  const SessionsDataSource({required ApiHttpExecutor executor})
    : _executor = executor;

  final ApiHttpExecutor _executor;

  /// Returns session details including speakers and tags.
  Future<Session> getSessionById({
    required String sessionID,
  }) async {
    final response = await _executor.client.get(
      _executor.uri(SessionPaths.byId(sessionID)),
      headers: await _executor.authHeaders(),
    );

    if (response.statusCode != 200) {
      throw GetSessionByIdFailure(
        'Request failed with status ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }

    final body = _executor.decodeJson(response.body);
    final errorJson = body['error'] as Map<String, dynamic>?;
    if (errorJson != null) {
      final error = ApiError.fromJson(errorJson);
      throw GetSessionByIdFailure(
        error.message,
        statusCode: response.statusCode,
        errorCode: error.code,
      );
    }

    final dataJson = body['data'] as Map<String, dynamic>?;
    if (dataJson == null) {
      throw GetSessionByIdFailure(
        'Missing data field in response',
        statusCode: response.statusCode,
      );
    }

    return Session.fromJson(dataJson);
  }

  /// Updates a session's lifecycle status.
  Future<Session> updateSessionStatus({
    required String eventID,
    required String sessionID,
    required String status,
  }) async {
    final response = await _executor.client.patch(
      _executor.uri(
        SessionPaths.updateStatus(eventID: eventID, sessionID: sessionID),
      ),
      headers: await _executor.authHeaders(),
      body: jsonEncode(<String, String>{'status': status}),
    );

    if (response.statusCode != 200) {
      throw UpdateSessionStatusFailure(
        'Request failed with status ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }

    final body = _executor.decodeJson(response.body);
    final errorJson = body['error'] as Map<String, dynamic>?;
    if (errorJson != null) {
      final error = ApiError.fromJson(errorJson);
      throw UpdateSessionStatusFailure(
        error.message,
        statusCode: response.statusCode,
        errorCode: error.code,
      );
    }

    final dataJson = body['data'] as Map<String, dynamic>?;
    if (dataJson == null) {
      throw UpdateSessionStatusFailure(
        'Missing data field in response',
        statusCode: response.statusCode,
      );
    }

    return Session.fromJson(dataJson);
  }
}
