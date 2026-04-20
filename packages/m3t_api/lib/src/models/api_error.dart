import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'api_error.g.dart';

@JsonSerializable()
final class ApiError extends Equatable {
  const ApiError({
    required this.code,
    required this.message,
    this.showToUser = false,
  });

  factory ApiError.fromJson(Map<String, dynamic> json) =>
      _$ApiErrorFromJson(json);

  final String code;
  final String message;

  @JsonKey(name: 'show_to_user', defaultValue: false)
  final bool showToUser;

  ApiError copyWith({
    String? code,
    String? message,
    bool? showToUser,
  }) {
    return ApiError(
      code: code ?? this.code,
      message: message ?? this.message,
      showToUser: showToUser ?? this.showToUser,
    );
  }

  Map<String, dynamic> toJson() => _$ApiErrorToJson(this);

  @override
  List<Object?> get props => [code, message, showToUser];
}
