import 'package:bloc_test/bloc_test.dart';
import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:m3t_organizer/features/event_selector/event_selector.dart';
import 'package:mocktail/mocktail.dart';

class _MockEventsRepository extends Mock implements EventsRepository {}

class _MockSelectedEventStorage extends Mock implements SelectedEventStorage {}

void main() {
  group('SelectedEventCubit', () {
    late EventsRepository eventsRepository;
    late SelectedEventStorage selectedEventStorage;

    const eventA = Event(id: 'event-a', name: 'Event A');
    const eventB = Event(id: 'event-b', name: 'Event B');
    const events = <Event>[eventA, eventB];

    setUp(() {
      eventsRepository = _MockEventsRepository();
      selectedEventStorage = _MockSelectedEventStorage();
    });

    SelectedEventCubit buildCubit() => SelectedEventCubit(
      eventsRepository: eventsRepository,
      selectedEventStorage: selectedEventStorage,
    );

    group('loadEvents', () {
      blocTest<SelectedEventCubit, SelectedEventState>(
        'selects persisted event when id is in list',
        build: buildCubit,
        setUp: () {
          when(() => eventsRepository.getMyEvents()).thenAnswer((_) async => events);
          when(() => selectedEventStorage.read()).thenAnswer((_) async => 'event-b');
          when(() => selectedEventStorage.write(any())).thenAnswer((_) async {});
        },
        act: (cubit) => cubit.loadEvents(),
        expect: () => <SelectedEventState>[
          const SelectedEventState(loading: true),
          const SelectedEventState(
            events: events,
            selectedEvent: eventB,
          ),
        ],
        verify: (_) {
          verify(() => selectedEventStorage.write('event-b')).called(1);
        },
      );

      blocTest<SelectedEventCubit, SelectedEventState>(
        'falls back to first event when persisted id is missing',
        build: buildCubit,
        setUp: () {
          when(() => eventsRepository.getMyEvents()).thenAnswer((_) async => events);
          when(() => selectedEventStorage.read()).thenAnswer((_) async => null);
          when(() => selectedEventStorage.write(any())).thenAnswer((_) async {});
        },
        act: (cubit) => cubit.loadEvents(),
        expect: () => <SelectedEventState>[
          const SelectedEventState(loading: true),
          const SelectedEventState(
            events: events,
            selectedEvent: eventA,
          ),
        ],
        verify: (_) {
          verify(() => selectedEventStorage.write('event-a')).called(1);
        },
      );

      blocTest<SelectedEventCubit, SelectedEventState>(
        'falls back to first event when persisted id is invalid',
        build: buildCubit,
        setUp: () {
          when(() => eventsRepository.getMyEvents()).thenAnswer((_) async => events);
          when(
            () => selectedEventStorage.read(),
          ).thenAnswer((_) async => 'unknown-event');
          when(() => selectedEventStorage.write(any())).thenAnswer((_) async {});
        },
        act: (cubit) => cubit.loadEvents(),
        expect: () => <SelectedEventState>[
          const SelectedEventState(loading: true),
          const SelectedEventState(
            events: events,
            selectedEvent: eventA,
          ),
        ],
        verify: (_) {
          verify(() => selectedEventStorage.write('event-a')).called(1);
        },
      );

      blocTest<SelectedEventCubit, SelectedEventState>(
        'clears storage when no events are available',
        build: buildCubit,
        setUp: () {
          when(
            () => eventsRepository.getMyEvents(),
          ).thenAnswer((_) async => const <Event>[]);
          when(() => selectedEventStorage.read()).thenAnswer((_) async => 'event-a');
          when(() => selectedEventStorage.clear()).thenAnswer((_) async {});
        },
        act: (cubit) => cubit.loadEvents(),
        expect: () => <SelectedEventState>[
          const SelectedEventState(loading: true),
          const SelectedEventState(events: []),
        ],
        verify: (_) {
          verify(() => selectedEventStorage.clear()).called(1);
          verifyNever(() => selectedEventStorage.write(any()));
        },
      );
    });

    group('selectEvent', () {
      blocTest<SelectedEventCubit, SelectedEventState>(
        'updates selected event and persists id',
        build: buildCubit,
        seed: () => const SelectedEventState(
          events: events,
          selectedEvent: eventA,
        ),
        setUp: () {
          when(() => selectedEventStorage.write(any())).thenAnswer((_) async {});
        },
        act: (cubit) => cubit.selectEvent(eventB),
        expect: () => <SelectedEventState>[
          const SelectedEventState(
            events: events,
            selectedEvent: eventB,
          ),
        ],
        verify: (_) {
          verify(() => selectedEventStorage.write('event-b')).called(1);
        },
      );
    });

    group('reset', () {
      blocTest<SelectedEventCubit, SelectedEventState>(
        'returns to initial state',
        build: buildCubit,
        seed: () => const SelectedEventState(
          events: events,
          selectedEvent: eventA,
        ),
        act: (cubit) => cubit.reset(),
        expect: () => <SelectedEventState>[const SelectedEventState()],
      );
    });
  });
}
