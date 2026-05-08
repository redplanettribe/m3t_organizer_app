// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mobile_remote_config_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MobileRemoteConfigResponse _$MobileRemoteConfigResponseFromJson(
  Map<String, dynamic> json,
) => MobileRemoteConfigResponse(
  androidStoreUrl: json['android_store_url'] as String,
  app: json['app'] as String,
  iosStoreUrl: json['ios_store_url'] as String,
  latestBuild: (json['latest_build'] as num).toInt(),
  latestVersion: json['latest_version'] as String,
  minBuild: (json['min_build'] as num).toInt(),
  minVersion: json['min_version'] as String,
  platform: json['platform'] as String,
);

Map<String, dynamic> _$MobileRemoteConfigResponseToJson(
  MobileRemoteConfigResponse instance,
) => <String, dynamic>{
  'android_store_url': instance.androidStoreUrl,
  'app': instance.app,
  'ios_store_url': instance.iosStoreUrl,
  'latest_build': instance.latestBuild,
  'latest_version': instance.latestVersion,
  'min_build': instance.minBuild,
  'min_version': instance.minVersion,
  'platform': instance.platform,
};
