import 'package:m3t_api/src/exceptions.dart';
import 'package:m3t_api/src/http/api_http_executor.dart';
import 'package:m3t_api/src/http/api_paths.dart';
import 'package:m3t_api/src/models/mobile_remote_config_response.dart';

final class RemoteConfigDataSource {
  const RemoteConfigDataSource({required ApiHttpExecutor executor})
    : _executor = executor;

  final ApiHttpExecutor _executor;

  Future<MobileRemoteConfigResponse> getMobileRemoteConfig({
    required String app,
    required String platform,
  }) async {
    final uri = _executor
        .uri(MobilePaths.remoteConfig)
        .replace(queryParameters: {'app': app, 'platform': platform});

    final response = await _executor.client.get(
      uri,
      headers: _executor.jsonHeaders,
    );

    final data = _executor.parseEnvelope(
      response,
      onError:
          ({
            required message,
            required statusCode,
            errorCode,
            showToUser = false,
          }) => GetMobileRemoteConfigFailure(
            message,
            statusCode: statusCode,
            errorCode: errorCode,
            showToUser: showToUser,
          ),
    );

    if (data == null) {
      throw GetMobileRemoteConfigFailure(
        'Missing data field in response',
        statusCode: response.statusCode,
      );
    }

    return MobileRemoteConfigResponse.fromJson(data);
  }
}
