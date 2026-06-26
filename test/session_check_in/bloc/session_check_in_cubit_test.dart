import 'package:bloc_test/bloc_test.dart';
import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:m3t_organizer/features/session_check_in/bloc/bloc.dart';
import 'package:mocktail/mocktail.dart';

class _MockEventsRepository extends Mock implements EventsRepository {}

void main() {
  group('SessionCheckInCubit', () {
    late EventsRepository eventsRepository;

    const eventID = 'event-1';
    const sessionID = 'session-1';
    const userID = 'user-a';

    late SessionCheckIn successCheckIn;

    setUp(() {
      eventsRepository = _MockEventsRepository();
      successCheckIn = SessionCheckIn(
        id: 'ci-1',
        sessionID: sessionID,
        userID: userID,
        checkedInBy: 'organizer',
        createdAt: DateTime.utc(2026),
        name: 'Ada',
      );
    });

    SessionCheckInCubit buildCubit() => SessionCheckInCubit(
      eventID: eventID,
      sessionID: sessionID,
      eventsRepository: eventsRepository,
    );

    group('setOverrideCapacity', () {
      blocTest<SessionCheckInCubit, SessionCheckInState>(
        'updates overrideCapacity in state',
        build: buildCubit,
        act: (cubit) => cubit.setOverrideCapacity(value: true),
        expect: () => const <SessionCheckInState>[
          SessionCheckInState(overrideCapacity: true),
        ],
      );
    });

    group('onUserIDScanned', () {
      blocTest<SessionCheckInCubit, SessionCheckInState>(
        'does not call repository again for duplicate user after success',
        build: buildCubit,
        setUp: () {
          when(
            () => eventsRepository.checkInAttendeeToSession(
              eventID: any(named: 'eventID'),
              sessionID: any(named: 'sessionID'),
              userID: any(named: 'userID'),
              overrideCapacity: any(named: 'overrideCapacity'),
            ),
          ).thenAnswer(
            (_) async => (checkIn: successCheckIn, alreadyCheckedIn: false),
          );
        },
        act: (cubit) async {
          await cubit.onUserIDScanned(userID);
          await cubit.onUserIDScanned(userID);
        },
        expect: () => <SessionCheckInState>[
          const SessionCheckInState(
            loading: true,
            lastScannedUserId: userID,
          ),
          SessionCheckInState(
            latestCheckIn: successCheckIn,
            lastScannedUserId: userID,
          ),
        ],
        verify: (_) {
          verify(
            () => eventsRepository.checkInAttendeeToSession(
              eventID: eventID,
              sessionID: sessionID,
              userID: userID,
            ),
          ).called(1);
        },
      );

      blocTest<SessionCheckInCubit, SessionCheckInState>(
        'passes overrideCapacity true when enabled',
        build: buildCubit,
        setUp: () {
          when(
            () => eventsRepository.checkInAttendeeToSession(
              eventID: any(named: 'eventID'),
              sessionID: any(named: 'sessionID'),
              userID: any(named: 'userID'),
              overrideCapacity: any(named: 'overrideCapacity'),
            ),
          ).thenAnswer(
            (_) async => (checkIn: successCheckIn, alreadyCheckedIn: false),
          );
        },
        act: (cubit) async {
          cubit.setOverrideCapacity(value: true);
          await cubit.onUserIDScanned(userID);
        },
        expect: () => <SessionCheckInState>[
          const SessionCheckInState(overrideCapacity: true),
          const SessionCheckInState(
            loading: true,
            lastScannedUserId: userID,
            overrideCapacity: true,
          ),
          SessionCheckInState(
            latestCheckIn: successCheckIn,
            lastScannedUserId: userID,
            overrideCapacity: true,
          ),
        ],
        verify: (_) {
          verify(
            () => eventsRepository.checkInAttendeeToSession(
              eventID: eventID,
              sessionID: sessionID,
              userID: userID,
              overrideCapacity: true,
            ),
          ).called(1);
        },
      );

      blocTest<SessionCheckInCubit, SessionCheckInState>(
        'allows retry for same user after failure',
        build: buildCubit,
        setUp: () {
          var callCount = 0;
          when(
            () => eventsRepository.checkInAttendeeToSession(
              eventID: any(named: 'eventID'),
              sessionID: any(named: 'sessionID'),
              userID: any(named: 'userID'),
              overrideCapacity: any(named: 'overrideCapacity'),
            ),
          ).thenAnswer((_) async {
            callCount++;
            if (callCount == 1) {
              throw EventsNetworkError();
            }
            return (checkIn: successCheckIn, alreadyCheckedIn: false);
          });
        },
        act: (cubit) async {
          await cubit.onUserIDScanned(userID);
          await cubit.onUserIDScanned(userID);
        },
        expect: () => <SessionCheckInState>[
          const SessionCheckInState(
            loading: true,
            lastScannedUserId: userID,
          ),
          const SessionCheckInState(
            lastScannedUserId: userID,
            errorMessage: 'A network error occurred. Please try again.',
          ),
          const SessionCheckInState(
            loading: true,
            lastScannedUserId: userID,
          ),
          SessionCheckInState(
            latestCheckIn: successCheckIn,
            lastScannedUserId: userID,
          ),
        ],
        verify: (_) {
          verify(
            () => eventsRepository.checkInAttendeeToSession(
              eventID: eventID,
              sessionID: sessionID,
              userID: userID,
            ),
          ).called(2);
        },
      );
    });
  });
}
