import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:m3t_organizer/features/chat/bloc/dm_inbox_cubit.dart';
import 'package:mocktail/mocktail.dart';

class _MockChatRepository extends Mock implements ChatRepository {}

class _MockEventsRepository extends Mock implements EventsRepository {}

void main() {
  group('DmInboxCubit', () {
    const eventId = 'evt-1';
    const currentUserId = 'user-self';

    final selfRegistration = EventRegistration(
      registrationId: 'reg-self',
      eventId: eventId,
      userId: currentUserId,
      name: 'Me',
      lastName: 'Organizer',
    );
    final otherRegistration = EventRegistration(
      registrationId: 'reg-2',
      eventId: eventId,
      userId: 'user-2',
      name: 'Ada',
      lastName: 'Lovelace',
      email: 'ada@example.com',
    );

    late _MockChatRepository chatRepository;
    late _MockEventsRepository eventsRepository;
    late StreamController<ChatRealtimeEvent> realtimeController;

    setUp(() {
      chatRepository = _MockChatRepository();
      eventsRepository = _MockEventsRepository();
      realtimeController = StreamController<ChatRealtimeEvent>.broadcast();

      when(
        () => chatRepository.getDmConversations(
          eventID: any(named: 'eventID'),
          limit: any(named: 'limit'),
          cursor: any(named: 'cursor'),
        ),
      ).thenAnswer(
        (_) async => const ChatConversationPage(items: [], nextCursor: null),
      );
    });

    tearDown(() async {
      await realtimeController.close();
    });

    DmInboxCubit buildCubit({bool autoInitialize = true}) => DmInboxCubit(
      chatRepository: chatRepository,
      eventsRepository: eventsRepository,
      eventID: eventId,
      currentUserId: currentUserId,
      realtimeEvents: realtimeController.stream,
      autoInitialize: autoInitialize,
    );

    test('searchAttendees returns empty list for blank query', () async {
      final cubit = buildCubit(autoInitialize: false);
      addTearDown(cubit.close);

      final results = await cubit.searchAttendees('   ');

      expect(results, isEmpty);
      verifyNever(
        () => eventsRepository.listEventRegistrations(
          eventID: any(named: 'eventID'),
          search: any(named: 'search'),
          page: any(named: 'page'),
          pageSize: any(named: 'pageSize'),
        ),
      );
    });

    test('searchAttendees returns matches excluding current user', () async {
      when(
        () => eventsRepository.listEventRegistrations(
          eventID: eventId,
          search: 'ada',
          page: 1,
          pageSize: 20,
        ),
      ).thenAnswer(
        (_) async => EventRegistrationPage(
          items: [otherRegistration, selfRegistration],
        ),
      );

      final cubit = buildCubit(autoInitialize: false);
      addTearDown(cubit.close);

      final results = await cubit.searchAttendees('ada');

      expect(results, equals([otherRegistration]));
      verify(
        () => eventsRepository.listEventRegistrations(
          eventID: eventId,
          search: 'ada',
          page: 1,
          pageSize: 20,
        ),
      ).called(1);
    });

    blocTest<DmInboxCubit, DmInboxState>(
      'searchAttendees emits errorMessage on EventsFailure',
      build: () => buildCubit(autoInitialize: false),
      act: (cubit) async {
        when(
          () => eventsRepository.listEventRegistrations(
            eventID: eventId,
            search: 'ada',
            page: 1,
            pageSize: 20,
          ),
        ).thenThrow(EventsForbidden());
        final results = await cubit.searchAttendees('ada');
        expect(results, isEmpty);
      },
      expect: () => [
        const DmInboxState(
          errorMessage:
              'You do not have permission to perform this action.',
        ),
      ],
    );

    blocTest<DmInboxCubit, DmInboxState>(
      'loadConversations resolves other participant name from registrations',
      build: () => buildCubit(autoInitialize: false),
      act: (cubit) async {
        final lastMessage = ChatMessage(
          messageId: 'msg-1',
          eventId: eventId,
          channelType: ChatChannelType.dm,
          conversationId: 'dm:evt-1:user-self:user-2',
          senderUserId: currentUserId,
          recipientUserId: 'user-2',
          body: 'Hello',
          createdAt: DateTime.utc(2026, 6, 8, 12),
        );
        when(
          () => chatRepository.getDmConversations(
            eventID: eventId,
            limit: 50,
            cursor: null,
          ),
        ).thenAnswer(
          (_) async => ChatConversationPage(
            items: [
              ChatConversation(
                conversationId: 'dm:evt-1:user-self:user-2',
                otherUserId: 'user-2',
                lastMessage: lastMessage,
              ),
            ],
          ),
        );
        when(
          () => eventsRepository.listEventRegistrations(
            eventID: eventId,
            page: 1,
            pageSize: 100,
          ),
        ).thenAnswer(
          (_) async => EventRegistrationPage(items: [otherRegistration]),
        );
        await cubit.loadConversations();
      },
      expect: () => [
        const DmInboxState(loading: true),
        DmInboxState(
          conversations: [
            ChatConversation(
              conversationId: 'dm:evt-1:user-self:user-2',
              otherUserId: 'user-2',
              lastMessage: ChatMessage(
                messageId: 'msg-1',
                eventId: eventId,
                channelType: ChatChannelType.dm,
                conversationId: 'dm:evt-1:user-self:user-2',
                senderUserId: currentUserId,
                recipientUserId: 'user-2',
                body: 'Hello',
                createdAt: DateTime.utc(2026, 6, 8, 12),
              ),
              otherParticipantDisplayName: 'Ada Lovelace',
            ),
          ],
        ),
      ],
    );
  });
}
