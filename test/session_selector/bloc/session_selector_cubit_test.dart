import 'package:bloc_test/bloc_test.dart';
import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:m3t_organizer/features/session_selector/bloc/session_selector_cubit.dart';
import 'package:mocktail/mocktail.dart';

class _MockEventsRepository extends Mock implements EventsRepository {}

class _FakeAgendaHandle implements OrganizerAgendaHandle {
  @override
  void cancel() {}
}

void main() {
  group('SessionSelectorCubit', () {
    const eventId = 'evt-1';
    const session = Session(
      id: 'ses-1',
      roomID: 'room-1',
      title: 'Talk',
      eventDay: 1,
      startTime: '09:00',
      endTime: '10:00',
      status: SessionStatus.scheduled,
    );
    const eventWithRooms = EventWithRooms(
      event: Event(id: eventId, name: 'Conf'),
      rooms: [
        RoomWithSessions(
          room: Room(
            id: 'room-1',
            eventID: eventId,
            name: 'Hall A',
            capacity: 100,
            notBookable: false,
          ),
          sessions: [session],
        ),
      ],
    );

    late _MockEventsRepository eventsRepository;
    void Function(OrganizerSessionStatusChanged)? realtimeCallback;

    setUp(() {
      eventsRepository = _MockEventsRepository();
      realtimeCallback = null;
      when(
        () => eventsRepository.getEventById(
          eventID: any(named: 'eventID'),
        ),
      ).thenAnswer((_) async => eventWithRooms);
      when(
        () => eventsRepository.connectOrganizerAgendaRealtime(
          eventID: any(named: 'eventID'),
          onSessionStatusChanged: any(named: 'onSessionStatusChanged'),
          onError: any(named: 'onError'),
        ),
      ).thenAnswer((invocation) {
        realtimeCallback =
            invocation.namedArguments[#onSessionStatusChanged]
                as void Function(OrganizerSessionStatusChanged);
        return _FakeAgendaHandle();
      });
    });

    SessionSelectorCubit buildCubit() => SessionSelectorCubit(
      eventID: eventId,
      eventsRepository: eventsRepository,
    );

    blocTest<SessionSelectorCubit, SessionSelectorState>(
      'loadEvent then realtime status updates session in rooms',
      build: buildCubit,
      act: (cubit) async {
        await cubit.loadEvent();
        realtimeCallback!(
          const OrganizerSessionStatusChanged(
            sessionId: 'ses-1',
            newStatus: SessionStatus.live,
          ),
        );
      },
      expect: () => <SessionSelectorState>[
        const SessionSelectorState(loading: true),
        SessionSelectorState(rooms: eventWithRooms.rooms),
        SessionSelectorState(
          rooms: [
            RoomWithSessions(
              room: eventWithRooms.rooms.first.room,
              sessions: [
                session.copyWith(status: SessionStatus.live),
              ],
            ),
          ],
        ),
      ],
    );

    test('close cancels organizer agenda handle', () async {
      OrganizerAgendaHandle? handle;
      when(
        () => eventsRepository.connectOrganizerAgendaRealtime(
          eventID: any(named: 'eventID'),
          onSessionStatusChanged: any(named: 'onSessionStatusChanged'),
          onError: any(named: 'onError'),
        ),
      ).thenAnswer((invocation) {
        handle = _RecordingHandle();
        realtimeCallback =
            invocation.namedArguments[#onSessionStatusChanged]
                as void Function(OrganizerSessionStatusChanged);
        return handle!;
      });

      final cubit = buildCubit();
      await cubit.loadEvent();
      expect(handle, isA<_RecordingHandle>());
      expect((handle! as _RecordingHandle).cancelled, isFalse);

      await cubit.close();
      expect((handle! as _RecordingHandle).cancelled, isTrue);
    });
  });
}

final class _RecordingHandle implements OrganizerAgendaHandle {
  bool cancelled = false;

  @override
  void cancel() {
    cancelled = true;
  }
}
