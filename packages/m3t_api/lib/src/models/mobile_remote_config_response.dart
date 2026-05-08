import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'mobile_remote_config_response.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
final class MobileRemoteConfigResponse extends Equatable {
  const MobileRemoteConfigResponse({
    required this.androidStoreUrl,
    required this.app,
    required this.iosStoreUrl,
    required this.latestBuild,
    required this.latestVersion,
    required this.minBuild,
    required this.minVersion,
    required this.platform,
  });

  factory MobileRemoteConfigResponse.fromJson(Map<String, dynamic> json) =>
      _$MobileRemoteConfigResponseFromJson(json);

  final String androidStoreUrl;
  final String app;
  final String iosStoreUrl;
  final int latestBuild;
  final String latestVersion;
  final int minBuild;
  final String minVersion;
  final String platform;

  MobileRemoteConfigResponse copyWith({
    String? androidStoreUrl,
    String? app,
    String? iosStoreUrl,
    int? latestBuild,
    String? latestVersion,
    int? minBuild,
    String? minVersion,
    String? platform,
  }) {
    return MobileRemoteConfigResponse(
      androidStoreUrl: androidStoreUrl ?? this.androidStoreUrl,
      app: app ?? this.app,
      iosStoreUrl: iosStoreUrl ?? this.iosStoreUrl,
      latestBuild: latestBuild ?? this.latestBuild,
      latestVersion: latestVersion ?? this.latestVersion,
      minBuild: minBuild ?? this.minBuild,
      minVersion: minVersion ?? this.minVersion,
      platform: platform ?? this.platform,
    );
  }

  Map<String, dynamic> toJson() => _$MobileRemoteConfigResponseToJson(this);

  @override
  List<Object?> get props => [
        androidStoreUrl,
        app,
        iosStoreUrl,
        latestBuild,
        latestVersion,
        minBuild,
        minVersion,
        platform,
      ];
}
