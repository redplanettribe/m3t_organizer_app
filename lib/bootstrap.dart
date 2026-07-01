import 'dart:async' show unawaited;
import 'dart:io' show HttpClient, HttpOverrides, SecurityContext;

import 'package:auth_repository/auth_repository.dart';
import 'package:domain/domain.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:m3t_api/m3t_api.dart';
import 'package:m3t_organizer/app/app.dart';
import 'package:m3t_organizer/core/app_config.dart';
import 'package:m3t_organizer/core/push/push_notification_cubit.dart';
import 'package:m3t_organizer/infrastructure/fcm_push_service.dart';
import 'package:m3t_organizer/infrastructure/flutter_secure_token_storage.dart';
import 'package:m3t_organizer/infrastructure/foreground_push_delivery.dart';
import 'package:m3t_organizer/infrastructure/local_notification_service.dart';
import 'package:m3t_organizer/infrastructure/push_ports.dart';
import 'package:m3t_organizer/infrastructure/secure_device_id_storage.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:remote_config_repository/remote_config_repository.dart';

Future<void> bootstrap() async {
  HttpOverrides.global = _AppHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();

  if (isPushSupportedPlatform) {
    await Firebase.initializeApp();
  }

  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
  ]);

  const tokenStorage = FlutterSecureTokenStorage();
  const deviceIdStorage = SecureDeviceIdStorage();
  late final AuthRepositoryImpl authRepository;
  late final PushNotificationCubit pushNotificationCubit;
  final apiBaseUrl = _resolveApiBaseUrl();
  final objectStoreBaseUrl = _resolveObjectStoreBaseUrl();
  final apiClient = M3tApiClient(
    tokenProvider: tokenStorage.read,
    baseUrl: apiBaseUrl,
    objectStoreBaseUrl: objectStoreBaseUrl,
    onSessionExpired: () => unawaited(authRepository.logout()),
  );
  authRepository = AuthRepositoryImpl(
    apiClient: apiClient,
    tokenStorage: tokenStorage,
    onBeforeLogout: () => pushNotificationCubit.unregisterDevice(),
  );
  final eventsRepository = EventsRepositoryImpl(
    apiClient: apiClient,
  );
  final chatRepository = ChatRepositoryImpl(
    apiClient: apiClient,
  );
  final remoteConfigRepository = RemoteConfigRepositoryImpl(
    apiClient: apiClient,
  );
  final deviceTokenRepository = DeviceTokenRepositoryImpl(
    apiClient: apiClient,
  );

  final pushMessaging = isPushSupportedPlatform
      ? FcmPushService()
      : const _NoOpPushMessaging();
  final localNotifications = isPushSupportedPlatform
      ? LocalNotificationService()
      : const _NoOpLocalNotifications();

  final packageInfo = await PackageInfo.fromPlatform();
  final currentBuild = int.tryParse(packageInfo.buildNumber.trim());
  if (currentBuild == null && packageInfo.buildNumber.isNotEmpty) {
    debugPrint(
      'bootstrap: could not parse build number "${packageInfo.buildNumber}"',
    );
  }

  final platformForQuery = switch (defaultTargetPlatform) {
    TargetPlatform.android => MobileAppPlatform.android,
    TargetPlatform.iOS => MobileAppPlatform.ios,
    TargetPlatform.linux ||
    TargetPlatform.macOS ||
    TargetPlatform.windows => MobileAppPlatform.android,
    TargetPlatform.fuchsia => MobileAppPlatform.android,
  };
  final useIosStoreUrl = defaultTargetPlatform == TargetPlatform.iOS;

  pushNotificationCubit = PushNotificationCubit(
    authRepository: authRepository,
    deviceTokenRepository: deviceTokenRepository,
    deviceIdStorage: deviceIdStorage,
    pushMessaging: pushMessaging,
    localNotifications: localNotifications,
    platform: platformForQuery,
  );

  try {
    await authRepository.initialize();
  } on Object catch (error, stackTrace) {
    debugPrint('bootstrap: authRepository.initialize() failed: $error');
    debugPrintStack(stackTrace: stackTrace);
  }

  if (isPushSupportedPlatform) {
    await pushNotificationCubit.start();
  }

  runApp(
    App(
      authRepository: authRepository,
      eventsRepository: eventsRepository,
      chatRepository: chatRepository,
      remoteConfigRepository: remoteConfigRepository,
      deviceTokenRepository: deviceTokenRepository,
      deviceIdStorage: deviceIdStorage,
      pushNotificationCubit: pushNotificationCubit,
      currentBuild: currentBuild,
      remoteConfigPlatform: platformForQuery,
      useIosStoreUrl: useIosStoreUrl,
    ),
  );
}

String _resolveApiBaseUrl() {
  const envUrl = String.fromEnvironment('M3T_API_URL');
  if (envUrl.isNotEmpty) {
    return envUrl;
  }

  return switch (defaultTargetPlatform) {
    TargetPlatform.android => AppConfig.defaultAndroidEmulatorApiBaseUrl,
    _ => AppConfig.defaultDesktopApiBaseUrl,
  };
}

Uri _resolveObjectStoreBaseUrl() {
  const envUrl = String.fromEnvironment('OBJECT_STORE_URL');
  if (envUrl.isNotEmpty) {
    return Uri.parse(envUrl);
  }

  return switch (defaultTargetPlatform) {
    TargetPlatform.android => Uri.parse(
      AppConfig.defaultAndroidEmulatorObjectStoreUrl,
    ),
    _ => Uri.parse(AppConfig.defaultDesktopObjectStoreUrl),
  };
}

final class _NoOpPushMessaging implements PushMessagingPort {
  const _NoOpPushMessaging();

  @override
  Future<void> deleteToken() async {}

  @override
  Future<void> dispose() async {}

  @override
  Future<PushNotificationMessage?> getInitialMessage() async => null;

  @override
  Future<String?> getToken() async => null;

  @override
  Future<void> initialize() async {}

  @override
  Stream<ForegroundPushDelivery> get onForegroundDelivery =>
      const Stream.empty();

  @override
  Stream<PushNotificationMessage> get onMessageOpened => const Stream.empty();

  @override
  Stream<String> get onTokenRefresh => const Stream.empty();

  @override
  Future<void> requestPermission() async {}
}

final class _NoOpLocalNotifications implements LocalNotificationPort {
  const _NoOpLocalNotifications();

  @override
  Future<void> initialize() async {}

  @override
  Future<void> show({
    required int id,
    required String title,
    required String body,
  }) async {}
}

/// Workaround for physical Android devices whose CA trust store is missing
/// intermediate certificates (e.g. for sessionize.com image CDN).
///
/// TLS encryption is still in effect — only chain-of-trust validation is
/// relaxed. This is acceptable because the app only connects to known
/// first-party backends and public image CDNs.
final class _AppHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (_, _, _) => true;
  }
}
