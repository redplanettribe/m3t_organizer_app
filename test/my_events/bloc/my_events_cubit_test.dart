import 'package:bloc_test/bloc_test.dart';
import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:m3t_organizer/features/my_events/my_events.dart';
import 'package:mocktail/mocktail.dart';

class _MockEventsRepository extends Mock implements EventsRepository {}

void main() {
  group('MyEventsCubit', () {
    late EventsRepository eventsRepository;

    const events = [
      Event(id: '1', name: 'Event 1'),
      Event(id: '2', name: 'Event 2'),
    ];

    setUp(() {
      eventsRepository = _MockEventsRepository();
    });

    MyEventsCubit buildCubit() =>
        MyEventsCubit(eventsRepository: eventsRepository);

    group('loadMyEvents', () {
      blocTest<MyEventsCubit, MyEventsState>(
        'emits loading then events on success',
        build: buildCubit,
        setUp: () {
          when(() => eventsRepository.getMyEvents()).thenAnswer(
            (_) async => events,
          );
        },
        act: (cubit) => cubit.loadMyEvents(),
        expect: () => <MyEventsState>[
          const MyEventsState(loading: true),
          const MyEventsState(events: events),
        ],
      );

      blocTest<MyEventsCubit, MyEventsState>(
        'emits human-readable errorMessage when EventsFailure occurs',
        build: buildCubit,
        setUp: () {
          when(() => eventsRepository.getMyEvents()).thenThrow(
            EventsNetworkError(),
          );
        },
        act: (cubit) => cubit.loadMyEvents(),
        expect: () => <MyEventsState>[
          const MyEventsState(loading: true),
          const MyEventsState(
            errorMessage: 'A network error occurred. Please try again.',
          ),
        ],
      );

      blocTest<MyEventsCubit, MyEventsState>(
        'emits generic errorMessage on unexpected Object error',
        build: buildCubit,
        setUp: () {
          when(() => eventsRepository.getMyEvents()).thenThrow(
            StateError('unexpected'),
          );
        },
        act: (cubit) => cubit.loadMyEvents(),
        expect: () => <MyEventsState>[
          const MyEventsState(loading: true),
          const MyEventsState(
            errorMessage: 'An unexpected error occurred. Please try again.',
          ),
        ],
      );
    });
  });
}

//
