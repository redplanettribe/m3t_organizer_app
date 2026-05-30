import 'package:http/http.dart' as http;
import 'package:m3t_api/src/exceptions.dart';
import 'package:m3t_api/src/http/api_http_executor.dart';
import 'package:test/test.dart';

M3tApiException _testError({
  required String message,
  required int statusCode,
  String? errorCode,
  bool showToUser = false,
}) {
  return GetCurrentUserFailure(
    message,
    statusCode: statusCode,
    errorCode: errorCode,
    showToUser: showToUser,
  );
}

http.Response _errorResponse({
  required int statusCode,
  required String body,
}) {
  return http.Response(body, statusCode);
}

void main() {
  group('ApiHttpExecutor session expiry', () {
    late ApiHttpExecutor executor;
    var sessionExpiredCallCount = 0;

    setUp(() {
      sessionExpiredCallCount = 0;
      executor = ApiHttpExecutor(
        httpClient: http.Client(),
        baseUrl: 'http://localhost:8080',
        onSessionExpired: () => sessionExpiredCallCount++,
      );
    });

    group('parseEnvelope', () {
      test('invokes onSessionExpired for invalid_or_expired_token', () {
        final response = _errorResponse(
          statusCode: 401,
          body: '''
{
  "error": {
    "code": "invalid_or_expired_token",
    "message": "Token expired",
    "show_to_user": true
  }
}
''',
        );

        expect(
          () => executor.parseEnvelope(
            response,
            onError: _testError,
          ),
          throwsA(isA<GetCurrentUserFailure>()),
        );
        expect(sessionExpiredCallCount, 1);
      });

      test('does not invoke onSessionExpired for other error codes', () {
        final response = _errorResponse(
          statusCode: 403,
          body: '''
{
  "error": {
    "code": "unauthorized",
    "message": "Not allowed"
  }
}
''',
        );

        expect(
          () => executor.parseEnvelope(
            response,
            onError: _testError,
          ),
          throwsA(isA<GetCurrentUserFailure>()),
        );
        expect(sessionExpiredCallCount, 0);
      });

      test('does not invoke onSessionExpired for generic 401 without envelope',
          () {
        final response = _errorResponse(
          statusCode: 401,
          body: '',
        );

        expect(
          () => executor.parseEnvelope(
            response,
            onError: _testError,
          ),
          throwsA(isA<GetCurrentUserFailure>()),
        );
        expect(sessionExpiredCallCount, 0);
      });
    });

    group('parseListEnvelope', () {
      test('invokes onSessionExpired for invalid_or_expired_token', () {
        final response = _errorResponse(
          statusCode: 401,
          body: '''
{
  "error": {
    "code": "invalid_or_expired_token",
    "message": "Token expired"
  }
}
''',
        );

        expect(
          () => executor.parseListEnvelope(
            response,
            onError: _testError,
          ),
          throwsA(isA<GetCurrentUserFailure>()),
        );
        expect(sessionExpiredCallCount, 1);
      });

      test('does not invoke onSessionExpired for other error codes', () {
        final response = _errorResponse(
          statusCode: 500,
          body: '''
{
  "error": {
    "code": "internal_error",
    "message": "Server error"
  }
}
''',
        );

        expect(
          () => executor.parseListEnvelope(
            response,
            onError: _testError,
          ),
          throwsA(isA<GetCurrentUserFailure>()),
        );
        expect(sessionExpiredCallCount, 0);
      });
    });
  });
}
