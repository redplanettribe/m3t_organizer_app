import 'package:bloc_test/bloc_test.dart';
import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:m3t_organizer/features/chat/general/bloc/general_chat_cubit.dart';
import 'package:mocktail/mocktail.dart';

class _MockChatRepository extends Mock implements ChatRepository {}

class _MockAuthRepository extends Mock implements AuthRepository {}

class _FakeChatHandle implements ChatRealtimeHandle {
  @override
  void cancel() {}
}

void main() {
  group('GeneralChatCubit', () {
    const eventId = 'evt-1';
    const user = AuthUser(id: 'user-1', email: 'a@b.com');
    final message = ChatMessage(
      messageId: 'msg-1',
      eventId: eventId,
      channelType: ChatChannelType.general,
      senderUserId: 'user-2',
      body: 'Hello',
      createdAt: DateTime.utc(2026, 6, 8, 12),
    );

    late _MockChatRepository chatRepository;
    late _MockAuthRepository authRepository;
    void Function(ChatRealtimeEvent)? realtimeCallback;

    setUp(() {
      chatRepository = _MockChatRepository();
      authRepository = _MockAuthRepository();
      realtimeCallback = null;

      when(() => authRepository.getCurrentUser()).thenAnswer((_) async => user);
      when(
        () => chatRepository.getGeneralMessages(
          eventID: any(named: 'eventID'),
          limit: any(named: 'limit'),
          cursor: any(named: 'cursor'),
        ),
      ).thenAnswer(
        (_) async => ChatMessagePage(items: [message], nextCursor: 'cursor-1'),
      );
      when(
        () => chatRepository.connectChatRealtime(
          eventID: any(named: 'eventID'),
          topics: any(named: 'topics'),
          onEvent: any(named: 'onEvent'),
          onError: any(named: 'onError'),
        ),
      ).thenAnswer((invocation) {
        realtimeCallback =
            invocation.namedArguments[#onEvent]
                as void Function(ChatRealtimeEvent);
        return _FakeChatHandle();
      });
    });

    GeneralChatCubit buildCubit({bool autoInitialize = true}) =>
        GeneralChatCubit(
          chatRepository: chatRepository,
          authRepository: authRepository,
          eventID: eventId,
          autoInitialize: autoInitialize,
        );

    blocTest<GeneralChatCubit, GeneralChatState>(
      'loads history and subscribes general topic on init',
      build: () => buildCubit(autoInitialize: false),
      act: (cubit) => cubit.initialize(),
      expect: () => [
        const GeneralChatState(status: GeneralChatStatus.loading),
        GeneralChatState(
          status: GeneralChatStatus.ready,
          messages: [message],
          nextCursor: 'cursor-1',
          currentUserId: user.id,
        ),
      ],
      verify: (_) {
        verify(() => authRepository.getCurrentUser()).called(1);
        verify(
          () => chatRepository.connectChatRealtime(
            eventID: eventId,
            topics: ['attendee.chat.evt-1.general'],
            onEvent: any(named: 'onEvent'),
            onError: any(named: 'onError'),
          ),
        ).called(1);
      },
    );

    blocTest<GeneralChatCubit, GeneralChatState>(
      'merges new realtime general message',
      build: () => buildCubit(autoInitialize: false),
      seed: () => GeneralChatState(
        status: GeneralChatStatus.ready,
        messages: [message],
        currentUserId: user.id,
      ),
      act: (cubit) {
        cubit.connectGeneralRealtimeForTest();
        final incoming = ChatMessage(
          messageId: 'msg-2',
          eventId: eventId,
          channelType: ChatChannelType.general,
          senderUserId: 'user-3',
          body: 'Hi',
          createdAt: DateTime.utc(2026, 6, 8, 12, 1),
        );
        realtimeCallback!(ChatMessageReceived(message: incoming));
      },
      expect: () => [
        GeneralChatState(
          status: GeneralChatStatus.ready,
          messages: [
            message,
            ChatMessage(
              messageId: 'msg-2',
              eventId: eventId,
              channelType: ChatChannelType.general,
              senderUserId: 'user-3',
              body: 'Hi',
              createdAt: DateTime.utc(2026, 6, 8, 12, 1),
            ),
          ],
          currentUserId: user.id,
        ),
      ],
    );

    blocTest<GeneralChatCubit, GeneralChatState>(
      'sendMessage appends returned message',
      build: () => buildCubit(autoInitialize: false),
      seed: () => GeneralChatState(
        status: GeneralChatStatus.ready,
        messages: [message],
        currentUserId: user.id,
      ),
      setUp: () {
        when(
          () => chatRepository.sendGeneralMessage(
            eventID: any(named: 'eventID'),
            body: any(named: 'body'),
            clientMsgId: any(named: 'clientMsgId'),
            replyToMessageId: any(named: 'replyToMessageId'),
          ),
        ).thenAnswer(
          (_) async => ChatMessage(
            messageId: 'msg-own',
            eventId: eventId,
            channelType: ChatChannelType.general,
            senderUserId: user.id,
            body: 'Sent',
            createdAt: DateTime.utc(2026, 6, 8, 12, 2),
          ),
        );
      },
      act: (cubit) => cubit.sendMessage('Sent'),
      expect: () => [
        GeneralChatState(
          status: GeneralChatStatus.ready,
          messages: [message],
          sending: true,
          currentUserId: user.id,
        ),
        GeneralChatState(
          status: GeneralChatStatus.ready,
          messages: [
            message,
            ChatMessage(
              messageId: 'msg-own',
              eventId: eventId,
              channelType: ChatChannelType.general,
              senderUserId: user.id,
              body: 'Sent',
              createdAt: DateTime.utc(2026, 6, 8, 12, 2),
            ),
          ],
          currentUserId: user.id,
        ),
      ],
    );

    blocTest<GeneralChatCubit, GeneralChatState>(
      'startReply and cancelReply update replyingTo',
      build: () => buildCubit(autoInitialize: false),
      seed: () => GeneralChatState(
        status: GeneralChatStatus.ready,
        messages: [message],
        currentUserId: user.id,
      ),
      act: (cubit) => cubit
        ..startReply(message)
        ..cancelReply(),
      expect: () => [
        GeneralChatState(
          status: GeneralChatStatus.ready,
          messages: [message],
          currentUserId: user.id,
          replyingTo: message,
        ),
        GeneralChatState(
          status: GeneralChatStatus.ready,
          messages: [message],
          currentUserId: user.id,
        ),
      ],
    );

    blocTest<GeneralChatCubit, GeneralChatState>(
      'sendMessage passes replyToMessageId when replying',
      build: () => buildCubit(autoInitialize: false),
      seed: () => GeneralChatState(
        status: GeneralChatStatus.ready,
        messages: [message],
        currentUserId: user.id,
        replyingTo: message,
      ),
      setUp: () {
        when(
          () => chatRepository.sendGeneralMessage(
            eventID: eventId,
            body: 'Reply body',
            clientMsgId: any(named: 'clientMsgId'),
            replyToMessageId: message.messageId,
          ),
        ).thenAnswer(
          (_) async => ChatMessage(
            messageId: 'msg-reply',
            eventId: eventId,
            channelType: ChatChannelType.general,
            senderUserId: user.id,
            body: 'Reply body',
            createdAt: DateTime.utc(2026, 6, 8, 12, 3),
            replyTo: ChatReplyTo(
              messageId: message.messageId,
              senderUserId: message.senderUserId,
              body: message.body,
            ),
          ),
        );
      },
      act: (cubit) => cubit.sendMessage('Reply body'),
      expect: () => [
        GeneralChatState(
          status: GeneralChatStatus.ready,
          messages: [message],
          sending: true,
          currentUserId: user.id,
          replyingTo: message,
        ),
        GeneralChatState(
          status: GeneralChatStatus.ready,
          messages: [
            message,
            ChatMessage(
              messageId: 'msg-reply',
              eventId: eventId,
              channelType: ChatChannelType.general,
              senderUserId: user.id,
              body: 'Reply body',
              createdAt: DateTime.utc(2026, 6, 8, 12, 3),
              replyTo: ChatReplyTo(
                messageId: message.messageId,
                senderUserId: message.senderUserId,
                body: message.body,
              ),
            ),
          ],
          currentUserId: user.id,
        ),
      ],
      verify: (_) {
        verify(
          () => chatRepository.sendGeneralMessage(
            eventID: eventId,
            body: 'Reply body',
            clientMsgId: any(named: 'clientMsgId'),
            replyToMessageId: message.messageId,
          ),
        ).called(1);
      },
    );
  });
}
