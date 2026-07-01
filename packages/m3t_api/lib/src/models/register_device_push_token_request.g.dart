// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register_device_push_token_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RegisterDevicePushTokenRequest _$RegisterDevicePushTokenRequestFromJson(
  Map<String, dynamic> json,
) => RegisterDevicePushTokenRequest(
  app: json['app'] as String,
  deviceId: json['device_id'] as String,
  platform: json['platform'] as String,
  token: json['token'] as String,
);

Map<String, dynamic> _$RegisterDevicePushTokenRequestToJson(
  RegisterDevicePushTokenRequest instance,
) => <String, dynamic>{
  'app': instance.app,
  'device_id': instance.deviceId,
  'platform': instance.platform,
  'token': instance.token,
};
