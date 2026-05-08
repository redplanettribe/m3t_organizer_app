import 'package:equatable/equatable.dart';

/// Remote configuration payload for mobile clients.
///
/// Backend contract: `GET /mobile/remote-config`.
final class MobileRemoteConfig extends Equatable {
  const MobileRemoteConfig({
    required this.app,
    required this.platform,
    required this.minBuild,
    required this.minVersion,
    required this.latestBuild,
    required this.latestVersion,
    required this.androidStoreUrl,
    required this.iosStoreUrl,
  });

  final String app;
  final String platform;

  /// Hard floor. Force update when `currentBuild < minBuild`.
  final int minBuild;
  final String minVersion;

  /// Informational latest.
  final int latestBuild;
  final String latestVersion;

  final Uri androidStoreUrl;
  final Uri iosStoreUrl;

  @override
  List<Object?> get props => [
    app,
    platform,
    minBuild,
    minVersion,
    latestBuild,
    latestVersion,
    androidStoreUrl,
    iosStoreUrl,
  ];
}
