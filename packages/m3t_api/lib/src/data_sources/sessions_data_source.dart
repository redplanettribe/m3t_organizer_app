import 'dart:convert';

import 'package:m3t_api/src/exceptions.dart';
import 'package:m3t_api/src/http/api_http_executor.dart';
import 'package:m3t_api/src/http/api_paths.dart';
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

    final data = _executor.parseEnvelope(
      response,
      onError:
          ({
            required message,
            required statusCode,
            errorCode,
            showToUser = false,
          }) => GetSessionByIdFailure(
            message,
            statusCode: statusCode,
            errorCode: errorCode,
            showToUser: showToUser,
          ),
    );

    if (data == null) {
      throw GetSessionByIdFailure(
        'Missing data field in response',
        statusCode: response.statusCode,
      );
    }

    return Session.fromJson(data);
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

    final data = _executor.parseEnvelope(
      response,
      onError:
          ({
            required message,
            required statusCode,
            errorCode,
            showToUser = false,
          }) => UpdateSessionStatusFailure(
            message,
            statusCode: statusCode,
            errorCode: errorCode,
            showToUser: showToUser,
          ),
    );

    if (data == null) {
      throw UpdateSessionStatusFailure(
        'Missing data field in response',
        statusCode: response.statusCode,
      );
    }

    return Session.fromJson(data);
  }
}
