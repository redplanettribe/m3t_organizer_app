import 'package:auth_repository/auth_repository.dart';
import 'package:domain/domain.dart';
import 'package:m3t_api/m3t_api.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockM3tApiClient extends Mock implements M3tApiClient {}

void main() {
  group('EventsRepositoryImpl', () {
    late _MockM3tApiClient apiClient;
    late EventsRepositoryImpl repository;

    const eventID = 'event-1';
    const sessionID = 'session-1';
    const deliverableID = 'deliverable-1';
    const userID = 'user-1';

    setUp(() {
      apiClient = _MockM3tApiClient();
      repository = EventsRepositoryImpl(apiClient: apiClient);
    });

    group('checkInAttendeeToSession() code-first mapping', () {
      final codeCases = <String, Matcher>{
        'session_full': isA<EventsSessionFull>(),
        'schedule_conflict': isA<EventsScheduleConflict>(),
        'session_all_attend': isA<EventsSessionAllAttend>(),
        'not_registered_for_event': isA<EventsNotRegisteredForEvent>(),
        'event_not_found': isA<EventsNotFound>(),
        'session_not_found': isA<EventsNotFound>(),
        'conflict': isA<EventsConflict>(),
        'session_not_live': isA<EventsConflict>(),
        'tier_not_allowed': isA<EventsForbidden>(),
        'not_event_owner': isA<EventsForbidden>(),
        'not_event_team_member': isA<EventsForbidden>(),
        'invalid_or_expired_token': isA<EventsInvalidOrExpiredToken>(),
      };

      for (final entry in codeCases.entries) {
        final code = entry.key;
        final matcher = entry.value;
        test('maps $code to the matching domain failure', () async {
          when(
            () => apiClient.checkInAttendeeToSession(
              eventID: any(named: 'eventID'),
              sessionID: any(named: 'sessionID'),
              userID: any(named: 'userID'),
            ),
          ).thenThrow(
            CheckInAttendeeToSessionFailure(
              'msg',
              statusCode: 409,
              errorCode: code,
            ),
          );

          await expectLater(
            repository.checkInAttendeeToSession(
              eventID: eventID,
              sessionID: sessionID,
              userID: userID,
            ),
            throwsA(matcher),
          );
        });
      }

      test(
        'falls back to status code when errorCode is null',
        () async {
          when(
            () => apiClient.checkInAttendeeToSession(
              eventID: any(named: 'eventID'),
              sessionID: any(named: 'sessionID'),
              userID: any(named: 'userID'),
            ),
          ).thenThrow(
            CheckInAttendeeToSessionFailure('x', statusCode: 409),
          );

          await expectLater(
            repository.checkInAttendeeToSession(
              eventID: eventID,
              sessionID: sessionID,
              userID: userID,
            ),
            throwsA(isA<EventsConflict>()),
          );
        },
      );

      test(
        'falls back to EventsNetworkError when neither code nor status match',
        () async {
          when(
            () => apiClient.checkInAttendeeToSession(
              eventID: any(named: 'eventID'),
              sessionID: any(named: 'sessionID'),
              userID: any(named: 'userID'),
            ),
          ).thenThrow(CheckInAttendeeToSessionFailure('x'));

          await expectLater(
            repository.checkInAttendeeToSession(
              eventID: eventID,
              sessionID: sessionID,
              userID: userID,
            ),
            throwsA(isA<EventsNetworkError>()),
          );
        },
      );
    });

    group('giveDeliverableToUser() code-first mapping', () {
      test('maps deliverable_already_given to EventsDeliverableAlreadyGiven',
          () async {
        when(
          () => apiClient.giveDeliverableToUser(
            eventID: any(named: 'eventID'),
            deliverableID: any(named: 'deliverableID'),
            userID: any(named: 'userID'),
            giveAnyway: any(named: 'giveAnyway'),
          ),
        ).thenThrow(
          GiveDeliverableFailure(
            'already',
            statusCode: 409,
            errorCode: 'deliverable_already_given',
          ),
        );

        await expectLater(
          repository.giveDeliverableToUser(
            eventID: eventID,
            deliverableID: deliverableID,
            userID: userID,
          ),
          throwsA(isA<EventsDeliverableAlreadyGiven>()),
        );
      });

      test('maps deliverable_not_found to EventsNotFound', () async {
        when(
          () => apiClient.giveDeliverableToUser(
            eventID: any(named: 'eventID'),
            deliverableID: any(named: 'deliverableID'),
            userID: any(named: 'userID'),
            giveAnyway: any(named: 'giveAnyway'),
          ),
        ).thenThrow(
          GiveDeliverableFailure(
            'missing',
            statusCode: 404,
            errorCode: 'deliverable_not_found',
          ),
        );

        await expectLater(
          repository.giveDeliverableToUser(
            eventID: eventID,
            deliverableID: deliverableID,
            userID: userID,
          ),
          throwsA(isA<EventsNotFound>()),
        );
      });

      test('maps not_event_team_member to EventsForbidden', () async {
        when(
          () => apiClient.giveDeliverableToUser(
            eventID: any(named: 'eventID'),
            deliverableID: any(named: 'deliverableID'),
            userID: any(named: 'userID'),
            giveAnyway: any(named: 'giveAnyway'),
          ),
        ).thenThrow(
          GiveDeliverableFailure(
            'forbidden',
            statusCode: 403,
            errorCode: 'not_event_team_member',
          ),
        );

        await expectLater(
          repository.giveDeliverableToUser(
            eventID: eventID,
            deliverableID: deliverableID,
            userID: userID,
          ),
          throwsA(isA<EventsForbidden>()),
        );
      });

      test('maps unprocessable_entity to EventsUnprocessableEntity', () async {
        when(
          () => apiClient.giveDeliverableToUser(
            eventID: any(named: 'eventID'),
            deliverableID: any(named: 'deliverableID'),
            userID: any(named: 'userID'),
            giveAnyway: any(named: 'giveAnyway'),
          ),
        ).thenThrow(
          GiveDeliverableFailure(
            'not eligible',
            statusCode: 422,
            errorCode: 'unprocessable_entity',
          ),
        );

        await expectLater(
          repository.giveDeliverableToUser(
            eventID: eventID,
            deliverableID: deliverableID,
            userID: userID,
          ),
          throwsA(isA<EventsUnprocessableEntity>()),
        );
      });
    });

    group('updateSessionStatus() code-first mapping', () {
      test(
        'maps live_session_conflict to EventsLiveSessionConflict',
        () async {
          when(
            () => apiClient.updateSessionStatus(
              eventID: any(named: 'eventID'),
              sessionID: any(named: 'sessionID'),
              status: any(named: 'status'),
            ),
          ).thenThrow(
            UpdateSessionStatusFailure(
              'live',
              statusCode: 409,
              errorCode: 'live_session_conflict',
            ),
          );

          await expectLater(
            repository.updateSessionStatus(
              eventID: eventID,
              sessionID: sessionID,
              status: SessionStatus.live,
            ),
            throwsA(isA<EventsLiveSessionConflict>()),
          );
        },
      );
    });

    group('getEventById() fallback mapping', () {
      test('maps 401 status to EventsUnauthorized', () async {
        when(
          () => apiClient.getEventById(eventID: any(named: 'eventID')),
        ).thenThrow(GetEventByIdFailure('x', statusCode: 401));

        await expectLater(
          repository.getEventById(eventID: eventID),
          throwsA(isA<EventsUnauthorized>()),
        );
      });

      test('maps 403 status to EventsForbidden', () async {
        when(
          () => apiClient.getEventById(eventID: any(named: 'eventID')),
        ).thenThrow(GetEventByIdFailure('x', statusCode: 403));

        await expectLater(
          repository.getEventById(eventID: eventID),
          throwsA(isA<EventsForbidden>()),
        );
      });

      test('maps 404 status to EventsNotFound', () async {
        when(
          () => apiClient.getEventById(eventID: any(named: 'eventID')),
        ).thenThrow(GetEventByIdFailure('x', statusCode: 404));

        await expectLater(
          repository.getEventById(eventID: eventID),
          throwsA(isA<EventsNotFound>()),
        );
      });
    });
  });
}
