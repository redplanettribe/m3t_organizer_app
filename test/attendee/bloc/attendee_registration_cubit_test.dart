import 'package:bloc_test/bloc_test.dart';
import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:m3t_organizer/features/attendee/bloc/attendee_registration_cubit.dart';
import 'package:mocktail/mocktail.dart';

class _MockEventsRepository extends Mock implements EventsRepository {}

void main() {
  group('AttendeeRegistrationCubit', () {
    const eventId = 'evt-1';
    const userId = 'user-2';

    final registration = EventRegistration(
      registrationId: 'reg-1',
      eventId: eventId,
      userId: userId,
      name: 'Alice',
      lastName: 'Smith',
      email: 'alice@example.com',
      checkedIn: true,
      tierName: 'VIP',
    );

    late _MockEventsRepository eventsRepository;

    setUp(() {
      eventsRepository = _MockEventsRepository();
    });

    AttendeeRegistrationCubit buildCubit() => AttendeeRegistrationCubit(
      eventsRepository: eventsRepository,
    );

    blocTest<AttendeeRegistrationCubit, AttendeeRegistrationState>(
      'emits ready when registration is found',
      build: buildCubit,
      setUp: () {
        when(
          () => eventsRepository.getEventRegistrationByUserId(
            eventID: eventId,
            userID: userId,
          ),
        ).thenAnswer((_) async => registration);
      },
      act: (cubit) => cubit.load(eventID: eventId, userID: userId),
      expect: () => [
        const AttendeeRegistrationState(
          status: AttendeeRegistrationStatus.loading,
        ),
        AttendeeRegistrationState(
          status: AttendeeRegistrationStatus.ready,
          registration: registration,
        ),
      ],
    );

    blocTest<AttendeeRegistrationCubit, AttendeeRegistrationState>(
      'emits notFound when registration is absent',
      build: buildCubit,
      setUp: () {
        when(
          () => eventsRepository.getEventRegistrationByUserId(
            eventID: eventId,
            userID: userId,
          ),
        ).thenAnswer((_) async => null);
      },
      act: (cubit) => cubit.load(eventID: eventId, userID: userId),
      expect: () => [
        const AttendeeRegistrationState(
          status: AttendeeRegistrationStatus.loading,
        ),
        const AttendeeRegistrationState(
          status: AttendeeRegistrationStatus.notFound,
        ),
      ],
    );

    blocTest<AttendeeRegistrationCubit, AttendeeRegistrationState>(
      'emits failure when repository throws EventsFailure',
      build: buildCubit,
      setUp: () {
        when(
          () => eventsRepository.getEventRegistrationByUserId(
            eventID: eventId,
            userID: userId,
          ),
        ).thenThrow(EventsForbidden());
      },
      act: (cubit) => cubit.load(eventID: eventId, userID: userId),
      expect: () => [
        const AttendeeRegistrationState(
          status: AttendeeRegistrationStatus.loading,
        ),
        isA<AttendeeRegistrationState>().having(
          (s) => s.status,
          'status',
          AttendeeRegistrationStatus.failure,
        ),
      ],
    );
  });
}
