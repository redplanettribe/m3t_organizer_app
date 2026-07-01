import 'dart:async';

import 'package:auth_repository/auth_repository.dart';
import 'package:domain/domain.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m3t_organizer/core/push/foreground_chat_tab.dart';
import 'package:m3t_organizer/core/push/push_navigation_intent.dart';
import 'package:m3t_organizer/infrastructure/foreground_push_delivery.dart';
import 'package:m3t_organizer/infrastructure/push_ports.dart';

part 'push_notification_state.dart';

/// Whether push is supported on the current platform.
bool get isPushSupportedPlatform {
  if (kIsWeb) {
    return false;
  }
  return switch (defaultTargetPlatform) {
    TargetPlatform.android || TargetPlatform.iOS => true,
    _ => false,
  };
}

/// Registers FCM tokens with the API and routes incoming push notifications.
final class PushNotificationCubit extends Cubit<PushNotificationState> {
  PushNotificationCubit({
    required AuthRepository authRepository,
    required DeviceTokenRepository deviceTokenRepository,
    required DeviceIdStorage deviceIdStorage,
    required PushMessagingPort pushMessaging,
    required LocalNotificationPort localNotifications,
    required MobileAppPlatform platform,
    String app = 'organizer',
  }) : _authRepository = authRepository,
       _deviceTokenRepository = deviceTokenRepository,
       _deviceIdStorage = deviceIdStorage,
       _pushMessaging = pushMessaging,
       _localNotifications = localNotifications,
       _platform = platform,
       _app = app,
       super(const PushNotificationState());

  final AuthRepository _authRepository;
  final DeviceTokenRepository _deviceTokenRepository;
  final DeviceIdStorage _deviceIdStorage;
  final PushMessagingPort _pushMessaging;
  final LocalNotificationPort _localNotifications;
  final MobileAppPlatform _platform;
  final String _app;

  final _seenDedupeKeys = <String>{};
  String? _chatNavEventId;
  ForegroundChatTab? _activeChatTab;
  String? _openDmEventId;
  String? _openDmConversationId;
  StreamSubscription<AuthStatus>? _authSubscription;
  StreamSubscription<String>? _tokenRefreshSubscription;
  StreamSubscription<ForegroundPushDelivery>? _foregroundSubscription;
  StreamSubscription<PushNotificationMessage>? _openedSubscription;

  Future<void> start() async {
    await _pushMessaging.initialize();
    await _localNotifications.initialize();
    await _pushMessaging.requestPermission();

    await _authSubscription?.cancel();
    _authSubscription = _authRepository.status.listen(_onAuthStatusChanged);

    await _tokenRefreshSubscription?.cancel();
    _tokenRefreshSubscription = _pushMessaging.onTokenRefresh.listen(
      (_) => unawaited(_registerCurrentToken()),
    );

    await _foregroundSubscription?.cancel();
    _foregroundSubscription = _pushMessaging.onForegroundDelivery.listen(
      _onForegroundDelivery,
    );

    await _openedSubscription?.cancel();
    _openedSubscription = _pushMessaging.onMessageOpened.listen(
      _routeFromMessage,
    );

    if (_authRepository.currentStatus == AuthStatus.authenticated) {
      await _registerCurrentToken();
    }

    final initialMessage = await _pushMessaging.getInitialMessage();
    if (initialMessage != null) {
      _routeFromMessage(initialMessage);
    }
  }

  /// Call before clearing the auth session so DELETE still has a JWT.
  Future<void> unregisterDevice() async {
    try {
      final deviceId = await _deviceIdStorage.readOrCreate();
      await _deviceTokenRepository.unregisterDeviceToken(
        deviceId: deviceId,
        app: _app,
      );
    } on DeviceTokenFailure catch (error, stackTrace) {
      addError(error, stackTrace);
    } on Object catch (error, stackTrace) {
      addError(error, stackTrace);
    }

    try {
      await _pushMessaging.deleteToken();
    } on Object catch (error, stackTrace) {
      addError(error, stackTrace);
    }
  }

  void clearPendingNavigation() {
    if (state.pendingNavigation == null) {
      return;
    }
    emit(state.copyWith(clearPendingNavigation: true));
  }

  /// Records a chat [messageId] delivered via WebSocket before push arrives.
  void rememberDeliveredMessage(String messageId) => _remember(messageId);

  @visibleForTesting
  void handleForegroundDeliveryForTest(ForegroundPushDelivery delivery) {
    _onForegroundDelivery(delivery);
  }

  void setEventChatNavActive({
    required String eventId,
    required bool active,
  }) {
    _chatNavEventId = active ? eventId.toLowerCase() : null;
    if (!active) {
      _activeChatTab = null;
    }
  }

  void setActiveChatTab({
    required String eventId,
    required ForegroundChatTab? tab,
  }) {
    if (_chatNavEventId != eventId.toLowerCase()) {
      return;
    }
    _activeChatTab = tab;
  }

  void setOpenDmThread({String? eventId, String? conversationId}) {
    _openDmEventId = eventId?.toLowerCase();
    _openDmConversationId = conversationId?.toLowerCase();
  }

  void clearChatForegroundPresence() {
    _chatNavEventId = null;
    _activeChatTab = null;
    _openDmEventId = null;
    _openDmConversationId = null;
  }

  Future<void> _onAuthStatusChanged(AuthStatus status) async {
    if (status == AuthStatus.authenticated) {
      await _registerCurrentToken();
    }
  }

  Future<void> _registerCurrentToken() async {
    if (_authRepository.currentStatus != AuthStatus.authenticated) {
      return;
    }

    final token = await _pushMessaging.getToken();
    if (token == null || token.isEmpty) {
      return;
    }

    try {
      final deviceId = await _deviceIdStorage.readOrCreate();
      await _deviceTokenRepository.registerDeviceToken(
        token: token,
        deviceId: deviceId,
        platform: _platform,
        app: _app,
      );
    } on DeviceTokenFailure catch (error, stackTrace) {
      addError(error, stackTrace);
    } on Object catch (error, stackTrace) {
      addError(error, stackTrace);
    }
  }

  void _onForegroundDelivery(ForegroundPushDelivery delivery) {
    if (_shouldSuppressForegroundBanner(delivery.message)) {
      return;
    }
    _remember(delivery.message.dedupeKey);

    final title = delivery.title ?? 'Notification';
    final body = delivery.body ?? '';
    if (body.isNotEmpty) {
      unawaited(
        _localNotifications.show(
          id: delivery.message.dedupeKey.hashCode,
          title: title,
          body: body,
        ),
      );
    }
  }

  void _routeFromMessage(PushNotificationMessage message) {
    if (_hasSeen(message.dedupeKey)) {
      return;
    }
    _remember(message.dedupeKey);
    emit(
      state.copyWith(
        pendingNavigation: PushNavigationIntent.fromMessage(message),
      ),
    );
  }

  bool _hasSeen(String dedupeKey) => _seenDedupeKeys.contains(dedupeKey);

  bool _shouldSuppressForegroundBanner(PushNotificationMessage message) {
    if (_hasSeen(message.dedupeKey)) {
      return true;
    }
    return switch (message) {
      OrganizerChatMessagePush(:final eventId) => _isViewingOrganizersChat(
        eventId,
      ),
      GeneralChatReplyPush(:final eventId) => _isViewingGeneralChat(eventId),
      DirectMessagePush(:final eventId, :final conversationId) =>
        _isViewingDmThread(eventId, conversationId),
      EventAnnouncementPush() => false,
    };
  }

  bool _isViewingOrganizersChat(String eventId) =>
      _chatNavEventId == eventId.toLowerCase() &&
      _activeChatTab == ForegroundChatTab.organizers;

  bool _isViewingGeneralChat(String eventId) =>
      _chatNavEventId == eventId.toLowerCase() &&
      _activeChatTab == ForegroundChatTab.general;

  bool _isViewingDmThread(String eventId, String conversationId) =>
      _openDmEventId == eventId.toLowerCase() &&
      _openDmConversationId == conversationId.toLowerCase();

  void _remember(String dedupeKey) {
    if (_seenDedupeKeys.length > 200) {
      _seenDedupeKeys.clear();
    }
    _seenDedupeKeys.add(dedupeKey);
  }

  @override
  Future<void> close() async {
    await _authSubscription?.cancel();
    await _tokenRefreshSubscription?.cancel();
    await _foregroundSubscription?.cancel();
    await _openedSubscription?.cancel();
    await _pushMessaging.dispose();
    return super.close();
  }
}
