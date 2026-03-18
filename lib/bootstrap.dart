import 'package:auth_repository/auth_repository.dart';
import 'package:flutter/widgets.dart';
import 'package:m3t_api/m3t_api.dart';
import 'package:m3t_organizer/app/app.dart';
import 'package:m3t_organizer/core/app_config.dart';
import 'package:m3t_organizer/infrastructure/flutter_secure_token_storage.dart';

Future<void> bootstrap() async {
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
