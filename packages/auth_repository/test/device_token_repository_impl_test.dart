import 'package:auth_repository/auth_repository.dart';
import 'package:domain/domain.dart';
import 'package:m3t_api/m3t_api.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockM3tApiClient extends Mock implements M3tApiClient {}

void main() {
  group('DeviceTokenRepositoryImpl', () {
    late _MockM3tApiClient apiClient;
    late DeviceTokenRepositoryImpl repository;

    setUp(() {
      apiClient = _MockM3tApiClient();
      repository = DeviceTokenRepositoryImpl(apiClient: apiClient);
    });

    test('registerDeviceToken delegates to api client', () async {
      when(
        () => apiClient.registerDevicePushToken(
          app: any(named: 'app'),
          deviceId: any(named: 'deviceId'),
          platform: any(named: 'platform'),
          token: any(named: 'token'),
        ),
      ).thenAnswer((_) async {});

      await repository.registerDeviceToken(
        token: 'fcm-token',
        deviceId: 'device-1',
        platform: MobileAppPlatform.android,
        app: 'organizer',
      );

      verify(
        () => apiClient.registerDevicePushToken(
          app: 'organizer',
          deviceId: 'device-1',
          platform: 'android',
          token: 'fcm-token',
        ),
      ).called(1);
    });

    test('unregisterDeviceToken delegates to api client', () async {
      when(
        () => apiClient.unregisterDevicePushToken(
          app: any(named: 'app'),
          deviceId: any(named: 'deviceId'),
        ),
      ).thenAnswer((_) async {});

      await repository.unregisterDeviceToken(
        deviceId: 'device-1',
        app: 'organizer',
      );

      verify(
        () => apiClient.unregisterDevicePushToken(
          app: 'organizer',
          deviceId: 'device-1',
        ),
      ).called(1);
    });

    test('maps unauthorized api error to domain failure', () async {
      when(
        () => apiClient.registerDevicePushToken(
          app: any(named: 'app'),
          deviceId: any(named: 'deviceId'),
          platform: any(named: 'platform'),
          token: any(named: 'token'),
        ),
      ).thenThrow(
        RegisterDevicePushTokenFailure(
          'unauthorized',
          statusCode: 401,
          errorCode: 'unauthorized',
        ),
      );

      await expectLater(
        repository.registerDeviceToken(
          token: 'fcm-token',
          deviceId: 'device-1',
          platform: MobileAppPlatform.ios,
          app: 'organizer',
        ),
        throwsA(isA<DeviceTokenUnauthorized>()),
      );
    });
  });
}
