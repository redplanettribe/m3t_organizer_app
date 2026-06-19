import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:m3t_organizer/core/remote_config/remote_config_cubit.dart';
import 'package:m3t_organizer/core/remote_config/view/app_update_gate.dart';
import 'package:mocktail/mocktail.dart';

class _MockRemoteConfigRepository extends Mock
    implements RemoteConfigRepository {}

void main() {
  late _MockRemoteConfigRepository remoteConfigRepository;

  setUpAll(() {
    registerFallbackValue(MobileAppPlatform.android);
  });

  setUp(() {
    remoteConfigRepository = _MockRemoteConfigRepository();
    when(
      () => remoteConfigRepository.getMobileRemoteConfig(
        app: any(named: 'app'),
        platform: any(named: 'platform'),
      ),
    ).thenAnswer(
      (_) async => MobileRemoteConfig(
        app: 'organizer',
        platform: 'android',
        minBuild: 1,
        minVersion: '1.0.0',
        latestBuild: 2,
        latestVersion: '2.0.0',
        androidStoreUrl: Uri.parse(
          'https://play.google.com/store/apps/details?id=com.example',
        ),
        iosStoreUrl: Uri.parse('https://apps.apple.com/app/id123'),
      ),
    );
    when(() => remoteConfigRepository.dispose()).thenAnswer((_) async {});
  });

  testWidgets('AppUpdateGate triggers remote config check on startup', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: RepositoryProvider<RemoteConfigRepository>.value(
          value: remoteConfigRepository,
          child: BlocProvider(
            create: (_) => RemoteConfigCubit(
              remoteConfigRepository: remoteConfigRepository,
              currentBuild: 100,
              app: 'organizer',
              platform: MobileAppPlatform.android,
              useIosStoreUrl: false,
            ),
            child: const AppUpdateGate(
              child: SizedBox.shrink(),
            ),
          ),
        ),
      ),
    );

    await tester.pump();

    verify(
      () => remoteConfigRepository.getMobileRemoteConfig(
        app: 'organizer',
        platform: MobileAppPlatform.android,
      ),
    ).called(1);
  });
}
