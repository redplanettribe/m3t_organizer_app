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
    when(() => remoteConfigRepository.dispose()).thenAnswer((_) async {});
    when(
      () => remoteConfigRepository.getMobileRemoteConfig(
        app: any(named: 'app'),
        platform: any(named: 'platform'),
      ),
    ).thenAnswer(
      (_) async => MobileRemoteConfig(
        app: 'organizer',
        platform: 'android',
        minBuild: 999,
        minVersion: '99.0.0',
        latestBuild: 999,
        latestVersion: '99.0.0',
        androidStoreUrl: Uri.parse('https://example.com/android'),
        iosStoreUrl: Uri.parse('https://example.com/ios'),
      ),
    );
  });

  testWidgets(
    'AppUpdateGate above MaterialApp shows force update without crash',
    (tester) async {
      await tester.pumpWidget(
        RepositoryProvider<RemoteConfigRepository>.value(
          value: remoteConfigRepository,
          child: BlocProvider(
            create: (_) => RemoteConfigCubit(
              remoteConfigRepository: remoteConfigRepository,
              currentBuild: 1,
              app: 'organizer',
              platform: MobileAppPlatform.android,
              useIosStoreUrl: false,
            ),
            child: const AppUpdateGate(
              child: MaterialApp(
                home: Scaffold(body: Text('main app')),
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Update required'), findsOneWidget);
    },
  );
}
