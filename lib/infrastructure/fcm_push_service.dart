import 'dart:async';

import 'package:domain/domain.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:m3t_organizer/infrastructure/fcm_background_handler.dart';
import 'package:m3t_organizer/infrastructure/foreground_push_delivery.dart';
import 'package:m3t_organizer/infrastructure/push_notification_message_parser.dart';
import 'package:m3t_organizer/infrastructure/push_ports.dart';

/// Flutter-side adapter for Firebase Cloud Messaging.
final class FcmPushService implements PushMessagingPort {
  FcmPushService({FirebaseMessaging? messaging})
    : _messaging = messaging ?? FirebaseMessaging.instance;

  final FirebaseMessaging _messaging;
  final _foregroundController =
      StreamController<ForegroundPushDelivery>.broadcast();
  final _openedController =
      StreamController<PushNotificationMessage>.broadcast();

  StreamSubscription<RemoteMessage>? _foregroundSubscription;
  StreamSubscription<RemoteMessage>? _openedSubscription;

  @override
  Stream<String> get onTokenRefresh => _messaging.onTokenRefresh;

  @override
  Stream<ForegroundPushDelivery> get onForegroundDelivery =>
      _foregroundController.stream;

  @override
  Stream<PushNotificationMessage> get onMessageOpened =>
      _openedController.stream;

  @override
  Future<void> initialize() async {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    await _foregroundSubscription?.cancel();
    _foregroundSubscription = FirebaseMessaging.onMessage.listen(
      _handleForegroundMessage,
    );

    await _openedSubscription?.cancel();
    _openedSubscription = FirebaseMessaging.onMessageOpenedApp.listen(
      _handleOpenedMessage,
    );
  }

  @override
  Future<void> requestPermission() async {
    await _messaging.requestPermission();
  }

  @override
  Future<String?> getToken() => _messaging.getToken();

  @override
  Future<PushNotificationMessage?> getInitialMessage() async {
    final message = await _messaging.getInitialMessage();
    if (message == null) {
      return null;
    }
    return parsePushNotificationMessage(message.data);
  }

  @override
  Future<void> deleteToken() => _messaging.deleteToken();

  @override
  Future<void> dispose() async {
    await _foregroundSubscription?.cancel();
    await _openedSubscription?.cancel();
    await _foregroundController.close();
    await _openedController.close();
  }

  void _handleForegroundMessage(RemoteMessage message) {
    final parsed = parsePushNotificationMessage(message.data);
    if (parsed == null) {
      debugPrint(
        'FcmPushService: ignored foreground message '
        'type=${message.data['type']}',
      );
      return;
    }

    _foregroundController.add(
      ForegroundPushDelivery(
        message: parsed,
        title: message.notification?.title,
        body: message.notification?.body,
      ),
    );
  }

  void _handleOpenedMessage(RemoteMessage message) {
    final parsed = parsePushNotificationMessage(message.data);
    if (parsed == null) {
      debugPrint(
        'FcmPushService: ignored opened message type=${message.data['type']}',
      );
      return;
    }
    _openedController.add(parsed);
  }
}
