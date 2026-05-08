import 'package:domain/src/entities/mobile_remote_config.dart';
import 'package:domain/src/enums/mobile_app_platform.dart';

abstract interface class RemoteConfigRepository {
  Future<MobileRemoteConfig> getMobileRemoteConfig({
    required String app,
    required MobileAppPlatform platform,
  });

  Future<void> dispose();
}
