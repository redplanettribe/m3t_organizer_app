import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:m3t_organizer/infrastructure/push_ports.dart';

/// Shows local notifications when FCM arrives in the foreground.
final class LocalNotificationService implements LocalNotificationPort {
  LocalNotificationService({
    FlutterLocalNotificationsPlugin? plugin,
  }) : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  static const _androidChannelId = 'm3t_organizer_push';
  static const _androidChannelName = 'Push notifications';

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  @override
  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/launcher_icon',
    );
    const iosSettings = DarwinInitializationSettings();
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
    );

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      final androidPlugin = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      await androidPlugin?.createNotificationChannel(
        const AndroidNotificationChannel(
          _androidChannelId,
          _androidChannelName,
          importance: Importance.high,
        ),
      );
    }

    _initialized = true;
  }

  @override
  Future<void> show({
    required int id,
    required String title,
    required String body,
  }) async {
    if (!_initialized) {
      return;
    }

    const androidDetails = AndroidNotificationDetails(
      _androidChannelId,
      _androidChannelName,
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: details,
    );
  }
}
