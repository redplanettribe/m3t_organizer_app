import 'package:bloc_test/bloc_test.dart';
import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:m3t_organizer/features/chat/bloc/chat_bans_cubit.dart';
import 'package:mocktail/mocktail.dart';

class _MockChatRepository extends Mock implements ChatRepository {}

class _MockEventsRepository extends Mock implements EventsRepository {}

void main() {
  group('ChatBansCubit', () {
    const eventId = 'evt-1';
    final banOne = ChatBan(
      userId: 'user-1',
      userName: 'Ada',
      userLastName: 'Lovelace',
      bannedAt: DateTime.utc(2026, 6, 9, 12),
    );
    final banTwo = ChatBan(
      userId: 'user-2',
      userName: 'Alan',
      userLastName: 'Turing',
      bannedAt: DateTime.utc(2026, 6, 10, 12),
    );

    late _MockChatRepository chatRepository;
    late _MockEventsRepository eventsRepository;

    setUp(() {
      chatRepository = _MockChatRepository();
      eventsRepository = _MockEventsRepository();

      when(
        () => chatRepository.listChatBans(
          eventID: any(named: 'eventID'),
          page: any(named: 'page'),
          pageSize: any(named: 'pageSize'),
        ),
      ).thenAnswer(
        (_) async => ChatBanPage(
          items: [banOne],
          page: 1,
          pageSize: 20,
          total: 2,
          totalPages: 2,
        ),
      );
    });

    ChatBansCubit buildCubit({bool autoInitialize = true}) => ChatBansCubit(
      chatRepository: chatRepository,
      eventsRepository: eventsRepository,
      eventID: eventId,
      autoInitialize: autoInitialize,
    );

    blocTest<ChatBansCubit, ChatBansState>(
      'loads first page on init',
      build: () => buildCubit(autoInitialize: false),
      act: (cubit) => cubit.loadInitial(),
      expect: () => [
        const ChatBansState(status: ChatBansStatus.loading),
        ChatBansState(
          status: ChatBansStatus.ready,
          bans: [banOne],
          page: 1,
          totalPages: 2,
        ),
      ],
      verify: (_) {
        verify(
          () => chatRepository.listChatBans(
            eventID: eventId,
            page: 1,
            pageSize: 20,
          ),
        ).called(1);
      },
    );

    blocTest<ChatBansCubit, ChatBansState>(
      'unban removes user from list',
      build: () => buildCubit(autoInitialize: false),
      seed: () => ChatBansState(
        status: ChatBansStatus.ready,
        bans: [banOne, banTwo],
        page: 1,
        totalPages: 1,
      ),
      act: (cubit) async {
        when(
          () => chatRepository.unbanChatUser(
            eventID: eventId,
            userID: banOne.userId,
          ),
        ).thenAnswer((_) async {});
        await cubit.unbanUser(banOne.userId);
      },
      expect: () => [
        ChatBansState(
          status: ChatBansStatus.ready,
          bans: [banTwo],
          page: 1,
          totalPages: 1,
        ),
      ],
    );

    blocTest<ChatBansCubit, ChatBansState>(
      'ban prepends new ban',
      build: () => buildCubit(autoInitialize: false),
      seed: () => ChatBansState(
        status: ChatBansStatus.ready,
        bans: [banTwo],
        page: 1,
        totalPages: 1,
      ),
      act: (cubit) async {
        when(
          () => chatRepository.banChatUser(
            eventID: eventId,
            userID: banOne.userId,
          ),
        ).thenAnswer((_) async => banOne);
        await cubit.banUser(banOne.userId);
      },
      expect: () => [
        ChatBansState(
          status: ChatBansStatus.ready,
          bans: [banTwo],
          page: 1,
          totalPages: 1,
          banningUserId: banOne.userId,
        ),
        ChatBansState(
          status: ChatBansStatus.ready,
          bans: [banOne, banTwo],
          page: 1,
          totalPages: 1,
        ),
      ],
    );

    blocTest<ChatBansCubit, ChatBansState>(
      'loadMore appends next page',
      build: () => buildCubit(autoInitialize: false),
      seed: () => ChatBansState(
        status: ChatBansStatus.ready,
        bans: [banOne],
        page: 1,
        totalPages: 2,
      ),
      act: (cubit) async {
        when(
          () => chatRepository.listChatBans(
            eventID: eventId,
            page: 2,
            pageSize: 20,
          ),
        ).thenAnswer(
          (_) async => ChatBanPage(
            items: [banTwo],
            page: 2,
            pageSize: 20,
            total: 2,
            totalPages: 2,
          ),
        );
        await cubit.loadMore();
      },
      expect: () => [
        ChatBansState(
          status: ChatBansStatus.ready,
          bans: [banOne],
          page: 1,
          totalPages: 2,
          loadingMore: true,
        ),
        ChatBansState(
          status: ChatBansStatus.ready,
          bans: [banOne, banTwo],
          page: 2,
          totalPages: 2,
        ),
      ],
    );
  });
}
