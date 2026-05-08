part of 'remote_config_cubit.dart';

enum RemoteConfigStatus { initial, checking, ok, forced }

final class RemoteConfigState extends Equatable {
  const RemoteConfigState({
    this.status = RemoteConfigStatus.initial,
    this.minBuild,
    this.minVersion,
    this.latestBuild,
    this.latestVersion,
    this.updateUrl,
    this.errorMessage,
  });

  final RemoteConfigStatus status;

  final int? minBuild;
  final String? minVersion;
  final int? latestBuild;
  final String? latestVersion;
  final Uri? updateUrl;

  final String? errorMessage;

  static const _sentinel = Object();

  RemoteConfigState copyWith({
    RemoteConfigStatus? status,
    int? minBuild,
    Object? minVersion = _sentinel,
    int? latestBuild,
    Object? latestVersion = _sentinel,
    Object? updateUrl = _sentinel,
    Object? errorMessage = _sentinel,
  }) {
    return RemoteConfigState(
      status: status ?? this.status,
      minBuild: minBuild ?? this.minBuild,
      minVersion: minVersion == _sentinel
          ? this.minVersion
          : minVersion as String?,
      latestBuild: latestBuild ?? this.latestBuild,
      latestVersion: latestVersion == _sentinel
          ? this.latestVersion
          : latestVersion as String?,
      updateUrl: updateUrl == _sentinel ? this.updateUrl : updateUrl as Uri?,
      errorMessage: errorMessage == _sentinel
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  @override
  List<Object?> get props => [
        status,
        minBuild,
        minVersion,
        latestBuild,
        latestVersion,
        updateUrl,
        errorMessage,
      ];
}
