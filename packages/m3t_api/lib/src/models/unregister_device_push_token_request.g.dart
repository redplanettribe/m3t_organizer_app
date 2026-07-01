// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unregister_device_push_token_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UnregisterDevicePushTokenRequest _$UnregisterDevicePushTokenRequestFromJson(
  Map<String, dynamic> json,
) => UnregisterDevicePushTokenRequest(
  app: json['app'] as String,
  deviceId: json['device_id'] as String,
);

Map<String, dynamic> _$UnregisterDevicePushTokenRequestToJson(
  UnregisterDevicePushTokenRequest instance,
) => <String, dynamic>{'app': instance.app, 'device_id': instance.deviceId};
