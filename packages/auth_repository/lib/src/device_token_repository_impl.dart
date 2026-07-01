import 'package:domain/domain.dart' as domain;
import 'package:m3t_api/m3t_api.dart' as api;

final class DeviceTokenRepositoryImpl implements domain.DeviceTokenRepository {
  DeviceTokenRepositoryImpl({required api.M3tApiClient apiClient})
    : _apiClient = apiClient;

  final api.M3tApiClient _apiClient;

  @override
  Future<void> registerDeviceToken({
    required String token,
    required String deviceId,
    required domain.MobileAppPlatform platform,
    required String app,
  }) async {
    try {
      await _apiClient.registerDevicePushToken(
        app: app,
        deviceId: deviceId,
        platform: platform.name,
        token: token,
      );
    } on api.M3tApiException catch (e) {
      _throwDeviceTokenFailure(e);
    } on Object {
      throw domain.DeviceTokenUnknownError();
    }
  }

  @override
  Future<void> unregisterDeviceToken({
    required String deviceId,
    required String app,
  }) async {
    try {
      await _apiClient.unregisterDevicePushToken(
        app: app,
        deviceId: deviceId,
      );
    } on api.M3tApiException catch (e) {
      _throwDeviceTokenFailure(e);
    } on Object {
      throw domain.DeviceTokenUnknownError();
    }
  }
}

Never _throwDeviceTokenFailure(api.M3tApiException e) {
  switch (e.errorCode) {
    case 'invalid_request_body':
      throw domain.DeviceTokenInvalidInput();
    case 'unauthorized':
      throw domain.DeviceTokenUnauthorized();
    case 'user_not_found':
      throw domain.DeviceTokenUserNotFound();
    case 'internal_error':
      throw domain.DeviceTokenUnknownError();
  }
  switch (e.statusCode) {
    case 400:
      throw domain.DeviceTokenInvalidInput();
    case 401:
      throw domain.DeviceTokenUnauthorized();
    case 404:
      throw domain.DeviceTokenUserNotFound();
    case 500:
      throw domain.DeviceTokenUnknownError();
  }
  throw domain.DeviceTokenNetworkError();
}
