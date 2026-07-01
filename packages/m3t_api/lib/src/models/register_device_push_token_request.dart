import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'register_device_push_token_request.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
final class RegisterDevicePushTokenRequest extends Equatable {
  const RegisterDevicePushTokenRequest({
    required this.app,
    required this.deviceId,
    required this.platform,
    required this.token,
  });

  factory RegisterDevicePushTokenRequest.fromJson(Map<String, dynamic> json) =>
      _$RegisterDevicePushTokenRequestFromJson(json);

  final String app;
  final String deviceId;
  final String platform;
  final String token;

  Map<String, dynamic> toJson() => _$RegisterDevicePushTokenRequestToJson(this);

  @override
  List<Object?> get props => [app, deviceId, platform, token];
}
