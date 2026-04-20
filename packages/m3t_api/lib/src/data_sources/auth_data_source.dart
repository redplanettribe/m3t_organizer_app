import 'dart:convert';

import 'package:m3t_api/src/exceptions.dart';
import 'package:m3t_api/src/http/api_http_executor.dart';
import 'package:m3t_api/src/http/api_paths.dart';
import 'package:m3t_api/src/models/login_response.dart';

/// Handles authentication API calls: request and verify login codes.
final class AuthDataSource {
  const AuthDataSource({required ApiHttpExecutor executor})
    : _executor = executor;

  final ApiHttpExecutor _executor;

  Future<void> requestLoginCode(String email) async {
    final response = await _executor.client.post(
      _executor.uri(AuthPaths.requestLoginCode),
      headers: _executor.jsonHeaders,
      body: jsonEncode(<String, String>{'email': email}),
    );

    _executor.parseEnvelope(
      response,
      onError:
          ({
            required message,
            required statusCode,
            errorCode,
            showToUser = false,
          }) => RequestLoginCodeFailure(
            message,
            statusCode: statusCode,
            errorCode: errorCode,
            showToUser: showToUser,
          ),
    );
  }

  Future<LoginResponse> verifyLoginCode({
    required String email,
    required String code,
  }) async {
    final response = await _executor.client.post(
      _executor.uri(AuthPaths.verifyLoginCode),
      headers: _executor.jsonHeaders,
      body: jsonEncode(<String, String>{
        'email': email,
        'code': code,
      }),
    );

    final data = _executor.parseEnvelope(
      response,
      onError:
          ({
            required message,
            required statusCode,
            errorCode,
            showToUser = false,
          }) => VerifyLoginCodeFailure(
            message,
            statusCode: statusCode,
            errorCode: errorCode,
            showToUser: showToUser,
          ),
    );

    if (data == null) {
      throw VerifyLoginCodeFailure(
        'Missing data field in response',
        statusCode: response.statusCode,
      );
    }

    return LoginResponse.fromJson(data);
  }
}
