import 'package:bloc_test/bloc_test.dart';
import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:m3t_organizer/features/chat/bloc/chat_cubit.dart';
import 'package:m3t_organizer/features/chat/bloc/chat_unread_cubit.dart';
import 'package:m3t_organizer/features/chat/widgets/unread_badge_label.dart';
import 'package:mocktail/mocktail.dart';

class _MockChatRepository extends Mock implements ChatRepository {}

class _FakeChatHandle implements ChatRealtimeHandle {
  @override
  void cancel() {}
}

void main() {
  group('formatUnreadCount', () {
    test('returns empty string for zero', () {
      expect(formatUnreadCount(0), equals(''));
    });

    test('returns digit string up to 9', () {
      expect(formatUnreadCount(9), equals('9'));
    });

    test('returns 9+ above 9', () {
      expect(formatUnreadCount(10), equals('9+'));
      expect(formatUnreadCount(99), equals('9+'));
    });
  });

  group('ChatUnreadState', () {
    test('sums dmsUnread and totalUnread', () {
      const state = ChatUnreadState(
        generalUnread: 2,
        organizersUnread: 1,
        dmUnreadByConversation: {'dm:a': 3, 'dm:b': 2},
      );

      expect(state.dmsUnread, equals(5));
      expect(state.totalUnread, equals(8));
      expect(state.dmUnreadFor('DM:A'), equals(3));
    });
  });

  group('ChatUnreadCubit', () {
    const eventId = 'evt-1';
    const currentUserId = 'user-1';

    late _MockChatRepository chatRepository;

    ChatMessage message({
      required String messageId,
      required ChatChannelType channelType,
      String senderUserId = 'user-2',
      String? conversationId,
    }) {
      return ChatMessage(
        messageId: messageId,
        eventId: eventId,
        channelType: channelType,
        conversationId: conversationId,
        senderUserId: senderUserId,
        body: 'Hello',
        createdAt: DateTime.utc(2026, 6, 8, 12),
      );
    }

    setUp(() {
      chatRepository = _MockChatRepository();
      when(
        () => chatRepository.connectChatRealtime(
          eventID: any(named: 'eventID'),
          topics: any(named: 'topics'),
          onEvent: any(named: 'onEvent'),
          onError: any(named: 'onError'),
        ),
      ).thenReturn(_FakeChatHandle());
    });

    ChatUnreadCubit buildCubit({String? userId = currentUserId}) =>
        ChatUnreadCubit(
          chatRepository: chatRepository,
          eventID: eventId,
          currentUserId: userId,
        );

    blocTest<ChatUnreadCubit, ChatUnreadState>(
      'subscribes to general, organizers, and dm inbox topics',
      build: buildCubit,
      verify: (_) {
        verify(
          () => chatRepository.connectChatRealtime(
            eventID: eventId,
            topics: [
              'attendee.chat.evt-1.general',
              'organizer.chat.evt-1',
              'attendee.chat.evt-1.dm.inbox',
            ],
            onEvent: any(named: 'onEvent'),
            onError: any(named: 'onError'),
          ),
        ).called(1);
      },
    );

    blocTest<ChatUnreadCubit, ChatUnreadState>(
      'increments general unread for messages from others',
      build: buildCubit,
      act: (cubit) => cubit.handleMessageForTest(
        message(messageId: 'msg-1', channelType: ChatChannelType.general),
      ),
      expect: () => [const ChatUnreadState(generalUnread: 1)],
    );

    blocTest<ChatUnreadCubit, ChatUnreadState>(
      'increments organizers unread',
      build: buildCubit,
      act: (cubit) => cubit.handleMessageForTest(
        message(messageId: 'msg-1', channelType: ChatChannelType.organizers),
      ),
      expect: () => [const ChatUnreadState(organizersUnread: 1)],
    );

    blocTest<ChatUnreadCubit, ChatUnreadState>(
      'increments dm unread per conversation',
      build: buildCubit,
      act: (cubit) => cubit.handleMessageForTest(
        message(
          messageId: 'msg-1',
          channelType: ChatChannelType.dm,
          conversationId: 'dm:conv-1',
        ),
      ),
      expect: () => [
        const ChatUnreadState(
          dmUnreadByConversation: {'dm:conv-1': 1},
        ),
      ],
    );

    blocTest<ChatUnreadCubit, ChatUnreadState>(
      'does not increment for own messages',
      build: buildCubit,
      act: (cubit) => cubit.handleMessageForTest(
        message(
          messageId: 'msg-1',
          channelType: ChatChannelType.general,
          senderUserId: currentUserId,
        ),
      ),
      expect: () => const <ChatUnreadState>[],
    );

    blocTest<ChatUnreadCubit, ChatUnreadState>(
      'does not increment when viewing general tab on chat nav',
      build: buildCubit,
      act: (cubit) {
        cubit
          ..setChatNavActive(active: true)
          ..setActiveSegmentedTab(ChatChannelTab.general)
          ..handleMessageForTest(
            message(messageId: 'msg-1', channelType: ChatChannelType.general),
          );
      },
      expect: () => const <ChatUnreadState>[],
    );

    blocTest<ChatUnreadCubit, ChatUnreadState>(
      'does not increment dm when viewing open thread',
      build: buildCubit,
      act: (cubit) {
        cubit
          ..setChatNavActive(active: true)
          ..setActiveSegmentedTab(ChatChannelTab.dms)
          ..setOpenDmConversation('dm:conv-1')
          ..handleMessageForTest(
            message(
              messageId: 'msg-1',
              channelType: ChatChannelType.dm,
              conversationId: 'dm:conv-1',
            ),
          );
      },
      expect: () => const <ChatUnreadState>[],
    );

    blocTest<ChatUnreadCubit, ChatUnreadState>(
      'clears general unread when general tab focused on chat nav',
      build: buildCubit,
      seed: () => const ChatUnreadState(generalUnread: 3),
      act: (cubit) {
        cubit
          ..setChatNavActive(active: true)
          ..setActiveSegmentedTab(ChatChannelTab.general);
      },
      expect: () => [const ChatUnreadState()],
    );

    blocTest<ChatUnreadCubit, ChatUnreadState>(
      'clears organizers unread when team tab focused on chat nav',
      build: buildCubit,
      seed: () => const ChatUnreadState(organizersUnread: 2),
      act: (cubit) {
        cubit
          ..setChatNavActive(active: true)
          ..setActiveSegmentedTab(ChatChannelTab.organizers);
      },
      expect: () => [const ChatUnreadState()],
    );

    blocTest<ChatUnreadCubit, ChatUnreadState>(
      'markDmConversationRead clears conversation count',
      build: buildCubit,
      seed: () => const ChatUnreadState(
        dmUnreadByConversation: {'dm:conv-1': 2, 'dm:conv-2': 1},
      ),
      act: (cubit) => cubit.markDmConversationRead('DM:conv-1'),
      expect: () => [
        const ChatUnreadState(
          dmUnreadByConversation: {'dm:conv-2': 1},
        ),
      ],
    );

    blocTest<ChatUnreadCubit, ChatUnreadState>(
      'dedupes message ids',
      build: buildCubit,
      act: (cubit) {
        final msg = message(
          messageId: 'msg-dup',
          channelType: ChatChannelType.general,
        );
        cubit
          ..handleMessageForTest(msg)
          ..handleMessageForTest(msg);
      },
      expect: () => [const ChatUnreadState(generalUnread: 1)],
    );

    blocTest<ChatUnreadCubit, ChatUnreadState>(
      'does not increment when current user id is null',
      build: () => buildCubit(userId: null),
      act: (cubit) => cubit.handleMessageForTest(
        message(messageId: 'msg-1', channelType: ChatChannelType.general),
      ),
      expect: () => const <ChatUnreadState>[],
    );
  });
}
