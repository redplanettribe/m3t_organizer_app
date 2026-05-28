import 'package:domain/domain.dart' as domain;
import 'package:m3t_api/m3t_api.dart' as api;
import 'package:remote_config_repository/src/mappers/mobile_remote_config_mapper.dart';

final class RemoteConfigRepositoryImpl
    implements domain.RemoteConfigRepository {
  RemoteConfigRepositoryImpl({required api.M3tApiClient apiClient})
    : _apiClient = apiClient;

  final api.M3tApiClient _apiClient;

  @override
  Future<domain.MobileRemoteConfig> getMobileRemoteConfig({
    required String app,
    required domain.MobileAppPlatform platform,
  }) async {
    try {
      final result = await _apiClient.getMobileRemoteConfig(
        app: app,
        platform: platform.name,
      );
      return result.toDomain();
    } on api.M3tApiException catch (e) {
      _throwRemoteConfigFailure(e);
    } on Object {
      throw domain.GetMobileRemoteConfigUnknownError();
    }
  }

  @override
  Future<void> dispose() async {}
}

Never _throwRemoteConfigFailure(api.M3tApiException e) {
  switch (e.errorCode) {
    case 'missing_query_param':
    case 'invalid_query_param':
    case 'invalid_request_body':
      throw domain.GetMobileRemoteConfigInvalidInput();
    case 'internal_error':
      throw domain.GetMobileRemoteConfigUnknownError();
  }
  switch (e.statusCode) {
    case 400:
      throw domain.GetMobileRemoteConfigInvalidInput();
    case 500:
      throw domain.GetMobileRemoteConfigUnknownError();
  }
  throw domain.GetMobileRemoteConfigNetworkError();
}
