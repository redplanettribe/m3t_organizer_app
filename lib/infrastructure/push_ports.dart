import 'dart:async';

import 'package:domain/domain.dart';
import 'package:m3t_organizer/infrastructure/foreground_push_delivery.dart';

/// Port for FCM — implemented in `lib/infrastructure/fcm_push_service.dart`.
abstract interface class PushMessagingPort {
  Future<void> initialize();

  Future<void> requestPermission();

  Future<String?> getToken();

  Future<void> deleteToken();

  Stream<String> get onTokenRefresh;

  Stream<ForegroundPushDelivery> get onForegroundDelivery;

  Stream<PushNotificationMessage> get onMessageOpened;

  Future<PushNotificationMessage?> getInitialMessage();

  Future<void> dispose();
}

/// Port for foreground notification banners.
abstract interface class LocalNotificationPort {
  Future<void> initialize();

  Future<void> show({
    required int id,
    required String title,
    required String body,
  });
}
