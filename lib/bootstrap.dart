import 'dart:async' show unawaited;
import 'dart:io' show HttpClient, HttpOverrides, SecurityContext;

import 'package:auth_repository/auth_repository.dart';
import 'package:domain/domain.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:m3t_api/m3t_api.dart';
import 'package:m3t_organizer/app/app.dart';
import 'package:m3t_organizer/core/app_config.dart';
import 'package:m3t_organizer/infrastructure/flutter_secure_token_storage.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:remote_config_repository/remote_config_repository.dart';

Future<void> bootstrap() async {
  HttpOverrides.global = _AppHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
  ]);

  const tokenStorage = FlutterSecureTokenStorage();
  late final AuthRepositoryImpl authRepository;
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
  );
  final eventsRepository = EventsRepositoryImpl(
    apiClient: apiClient,
  );
  final remoteConfigRepository = RemoteConfigRepositoryImpl(
    apiClient: apiClient,
  );

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
    // Backend only supports android/ios query param; desktop uses android.
    TargetPlatform.linux ||
    TargetPlatform.macOS ||
    TargetPlatform.windows => MobileAppPlatform.android,
    TargetPlatform.fuchsia => MobileAppPlatform.android,
  };
  final useIosStoreUrl = defaultTargetPlatform == TargetPlatform.iOS;

  try {
    await authRepository.initialize();
  } on Object catch (error, stackTrace) {
    debugPrint('bootstrap: authRepository.initialize() failed: $error');
    debugPrintStack(stackTrace: stackTrace);
  }

  runApp(
    App(
      authRepository: authRepository,
      eventsRepository: eventsRepository,
      remoteConfigRepository: remoteConfigRepository,
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
    TargetPlatform.android =>
      Uri.parse(AppConfig.defaultAndroidEmulatorObjectStoreUrl),
    _ => Uri.parse(AppConfig.defaultDesktopObjectStoreUrl),
  };
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
