import 'package:domain/src/enums/mobile_app_platform.dart';

abstract interface class DeviceTokenRepository {
  Future<void> registerDeviceToken({
    required String token,
    required String deviceId,
    required MobileAppPlatform platform,
    required String app,
  });

  Future<void> unregisterDeviceToken({
    required String deviceId,
    required String app,
  });
}
