import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'unregister_device_push_token_request.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
final class UnregisterDevicePushTokenRequest extends Equatable {
  const UnregisterDevicePushTokenRequest({
    required this.app,
    required this.deviceId,
  });

  factory UnregisterDevicePushTokenRequest.fromJson(
    Map<String, dynamic> json,
  ) => _$UnregisterDevicePushTokenRequestFromJson(json);

  final String app;
  final String deviceId;

  Map<String, dynamic> toJson() =>
      _$UnregisterDevicePushTokenRequestToJson(this);

  @override
  List<Object?> get props => [app, deviceId];
}
