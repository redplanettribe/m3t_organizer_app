import 'package:domain/domain.dart' as domain;
import 'package:m3t_api/m3t_api.dart' as api;

extension MobileRemoteConfigMapper on api.MobileRemoteConfigResponse {
  domain.MobileRemoteConfig toDomain() {
    return domain.MobileRemoteConfig(
      app: app,
      platform: platform,
      minBuild: minBuild,
      minVersion: minVersion,
      latestBuild: latestBuild,
      latestVersion: latestVersion,
      androidStoreUrl: Uri.parse(androidStoreUrl),
      iosStoreUrl: Uri.parse(iosStoreUrl),
    );
  }
}
