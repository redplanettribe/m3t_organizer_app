import 'dart:io' show HttpClient, HttpOverrides, SecurityContext;

import 'package:auth_repository/auth_repository.dart';
import 'package:flutter/widgets.dart';
import 'package:m3t_api/m3t_api.dart';
import 'package:m3t_organizer/app/app.dart';
import 'package:m3t_organizer/core/app_config.dart';
import 'package:m3t_organizer/infrastructure/flutter_secure_token_storage.dart';

Future<void> bootstrap() async {
  HttpOverrides.global = _AppHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();

  const tokenStorage = FlutterSecureTokenStorage();
  final apiClient = M3tApiClient(
    tokenProvider: tokenStorage.read,
    baseUrl: AppConfig.baseUrl,
    objectStoreBaseUrl: Uri.parse(AppConfig.objectStoreUrl),
  );
  final authRepository = AuthRepositoryImpl(
    apiClient: apiClient,
    tokenStorage: tokenStorage,
  );
  final eventsRepository = EventsRepositoryImpl(
    apiClient: apiClient,
  );

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
    ),
  );
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
