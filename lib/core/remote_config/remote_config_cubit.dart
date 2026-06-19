import 'dart:async' show unawaited;

import 'package:domain/domain.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'remote_config_state.dart';

final class RemoteConfigCubit extends Cubit<RemoteConfigState> {
  RemoteConfigCubit({
    required RemoteConfigRepository remoteConfigRepository,
    required int? currentBuild,
    required String app,
    required MobileAppPlatform platform,
    required bool useIosStoreUrl,
  }) : _remoteConfigRepository = remoteConfigRepository,
       _currentBuild = currentBuild,
       _app = app,
       _platform = platform,
       _useIosStoreUrl = useIosStoreUrl,
       super(const RemoteConfigState()) {
    checkUnawaited();
  }

  final RemoteConfigRepository _remoteConfigRepository;
  final int? _currentBuild;
  final String _app;
  final MobileAppPlatform _platform;
  final bool _useIosStoreUrl;

  Future<void> check() async {
    if (state.status == RemoteConfigStatus.checking) {
      return;
    }

    emit(state.copyWith(status: RemoteConfigStatus.checking));

    try {
      final config = await _remoteConfigRepository.getMobileRemoteConfig(
        app: _app,
        platform: _platform,
      );

      final currentBuild = _currentBuild;
      if (currentBuild != null && currentBuild < config.minBuild) {
        final updateUrl = _useIosStoreUrl
            ? config.iosStoreUrl
            : config.androidStoreUrl;
        emit(
          state.copyWith(
            status: RemoteConfigStatus.forced,
            minBuild: config.minBuild,
            minVersion: config.minVersion,
            latestBuild: config.latestBuild,
            latestVersion: config.latestVersion,
            updateUrl: updateUrl,
            errorMessage: null,
          ),
        );
        return;
      }

      emit(
        state.copyWith(
          status: RemoteConfigStatus.ok,
          minBuild: config.minBuild,
          minVersion: config.minVersion,
          latestBuild: config.latestBuild,
          latestVersion: config.latestVersion,
          updateUrl: null,
          errorMessage: null,
        ),
      );
    } on GetMobileRemoteConfigFailure catch (e, st) {
      addError(e, st);

      // Sticky forced-update: once forced, transient errors never unlock.
      if (state.status == RemoteConfigStatus.forced) {
        emit(state.copyWith(status: RemoteConfigStatus.forced));
        return;
      }

      // Fail-open: don't lock users out on remote-config outage.
      emit(
        state.copyWith(
          status: RemoteConfigStatus.ok,
          errorMessage: 'Could not check for updates. Try again later.',
        ),
      );
    } on Object catch (e, st) {
      addError(e, st);
      if (state.status == RemoteConfigStatus.forced) {
        emit(state.copyWith(status: RemoteConfigStatus.forced));
        return;
      }
      emit(
        state.copyWith(
          status: RemoteConfigStatus.ok,
          errorMessage: 'Could not check for updates. Try again later.',
        ),
      );
    }
  }

  void checkUnawaited() => unawaited(check());
}
