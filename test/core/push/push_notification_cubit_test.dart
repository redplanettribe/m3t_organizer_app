import 'dart:async';

import 'package:auth_repository/auth_repository.dart';
import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:m3t_organizer/core/push/foreground_chat_tab.dart';
import 'package:m3t_organizer/core/push/push_notification_cubit.dart';
import 'package:m3t_organizer/infrastructure/foreground_push_delivery.dart';
import 'package:m3t_organizer/infrastructure/push_ports.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockDeviceTokenRepository extends Mock
    implements DeviceTokenRepository {}

class _MockDeviceIdStorage extends Mock implements DeviceIdStorage {}

class _MockPushMessagingPort extends Mock implements PushMessagingPort {}

class _MockLocalNotificationPort extends Mock
    implements LocalNotificationPort {}

void main() {
  group('PushNotificationCubit foreground suppression', () {
    late _MockAuthRepository authRepository;
    late _MockDeviceTokenRepository deviceTokenRepository;
    late _MockDeviceIdStorage deviceIdStorage;
    late _MockPushMessagingPort pushMessaging;
    late _MockLocalNotificationPort localNotifications;

    const eventId = '550e8400-e29b-41d4-a716-446655440000';
    const messageId = '6ba7b810-9dad-11d1-80b4-00c04fd430c8';
    const conversationId =
        'dm:550e8400-e29b-41d4-a716-446655440000:'
        'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee:'
        'ffffffff-1111-2222-3333-444444444444';

    setUp(() {
      authRepository = _MockAuthRepository();
      deviceTokenRepository = _MockDeviceTokenRepository();
      deviceIdStorage = _MockDeviceIdStorage();
      pushMessaging = _MockPushMessagingPort();
      localNotifications = _MockLocalNotificationPort();

      when(() => authRepository.status).thenAnswer((_) => const Stream.empty());
      when(() => authRepository.currentStatus).thenReturn(AuthStatus.unknown);
      when(
        () => pushMessaging.onTokenRefresh,
      ).thenAnswer((_) => const Stream.empty());
      when(
        () => pushMessaging.onForegroundDelivery,
      ).thenAnswer((_) => const Stream.empty());
      when(
        () => pushMessaging.onMessageOpened,
      ).thenAnswer((_) => const Stream.empty());
      when(
        () => pushMessaging.getInitialMessage(),
      ).thenAnswer((_) async => null);
      when(() => pushMessaging.dispose()).thenAnswer((_) async {});
      when(
        () => localNotifications.show(
          id: any(named: 'id'),
          title: any(named: 'title'),
          body: any(named: 'body'),
        ),
      ).thenAnswer((_) async {});
    });

    PushNotificationCubit buildCubit() {
      return PushNotificationCubit(
        authRepository: authRepository,
        deviceTokenRepository: deviceTokenRepository,
        deviceIdStorage: deviceIdStorage,
        pushMessaging: pushMessaging,
        localNotifications: localNotifications,
        platform: MobileAppPlatform.android,
      );
    }

    ForegroundPushDelivery organizersDelivery() {
      return const ForegroundPushDelivery(
        message: OrganizerChatMessagePush(
          eventId: eventId,
          messageId: messageId,
          senderName: 'Ada Lovelace',
          senderUserId: 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee',
        ),
        title: 'Ada Lovelace',
        body: 'Hello team',
      );
    }

    ForegroundPushDelivery generalReplyDelivery() {
      return const ForegroundPushDelivery(
        message: GeneralChatReplyPush(
          eventId: eventId,
          messageId: messageId,
          replyToMessageId: '550e8400-e29b-41d4-a716-446655440099',
          senderName: 'Ada Lovelace',
          senderUserId: 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee',
        ),
        title: 'Ada Lovelace',
        body: 'Reply text',
      );
    }

    ForegroundPushDelivery directMessageDelivery() {
      return const ForegroundPushDelivery(
        message: DirectMessagePush(
          eventId: eventId,
          messageId: messageId,
          conversationId: conversationId,
          senderName: 'Ada Lovelace',
          senderUserId: 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee',
        ),
        title: 'Ada Lovelace',
        body: 'DM text',
      );
    }

    test('shows local notification for new foreground chat push', () {
      final cubit = buildCubit();
      addTearDown(cubit.close);

      cubit.handleForegroundDeliveryForTest(organizersDelivery());

      verify(
        () => localNotifications.show(
          id: messageId.hashCode,
          title: 'Ada Lovelace',
          body: 'Hello team',
        ),
      ).called(1);
    });

    test('suppresses foreground push when message_id already remembered', () {
      final cubit = buildCubit();
      addTearDown(cubit.close);

      cubit
        ..rememberDeliveredMessage(messageId)
        ..handleForegroundDeliveryForTest(organizersDelivery());

      verifyNever(
        () => localNotifications.show(
          id: any(named: 'id'),
          title: any(named: 'title'),
          body: any(named: 'body'),
        ),
      );
    });

    test('suppresses organizer chat push when viewing Team tab', () {
      final cubit = buildCubit();
      addTearDown(cubit.close);

      cubit
        ..setEventChatNavActive(eventId: eventId, active: true)
        ..setActiveChatTab(
          eventId: eventId,
          tab: ForegroundChatTab.organizers,
        )
        ..handleForegroundDeliveryForTest(organizersDelivery());

      verifyNever(
        () => localNotifications.show(
          id: any(named: 'id'),
          title: any(named: 'title'),
          body: any(named: 'body'),
        ),
      );
    });

    test('suppresses general reply push when viewing General tab', () {
      final cubit = buildCubit();
      addTearDown(cubit.close);

      cubit
        ..setEventChatNavActive(eventId: eventId, active: true)
        ..setActiveChatTab(
          eventId: eventId,
          tab: ForegroundChatTab.general,
        )
        ..handleForegroundDeliveryForTest(generalReplyDelivery());

      verifyNever(
        () => localNotifications.show(
          id: any(named: 'id'),
          title: any(named: 'title'),
          body: any(named: 'body'),
        ),
      );
    });

    test('suppresses DM push when matching thread is open', () {
      final cubit = buildCubit();
      addTearDown(cubit.close);

      cubit
        ..setOpenDmThread(
          eventId: eventId,
          conversationId: conversationId,
        )
        ..handleForegroundDeliveryForTest(directMessageDelivery());

      verifyNever(
        () => localNotifications.show(
          id: any(named: 'id'),
          title: any(named: 'title'),
          body: any(named: 'body'),
        ),
      );
    });

    test('shows DM push when open thread is a different conversation', () {
      final cubit = buildCubit();
      addTearDown(cubit.close);

      cubit
        ..setOpenDmThread(
          eventId: eventId,
          conversationId: 'dm:other:conversation:id',
        )
        ..handleForegroundDeliveryForTest(directMessageDelivery());

      verify(
        () => localNotifications.show(
          id: messageId.hashCode,
          title: 'Ada Lovelace',
          body: 'DM text',
        ),
      ).called(1);
    });
  });
}
