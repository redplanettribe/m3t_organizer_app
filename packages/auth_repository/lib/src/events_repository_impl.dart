import 'package:auth_repository/src/mappers/deliverable_giveaway_mapper.dart';
import 'package:auth_repository/src/mappers/event_check_in_mapper.dart';
import 'package:auth_repository/src/mappers/event_deliverable_mapper.dart';
import 'package:auth_repository/src/mappers/event_mapper.dart';
import 'package:auth_repository/src/mappers/get_event_by_id_response_mapper.dart';
import 'package:auth_repository/src/mappers/session_check_in_mapper.dart';
import 'package:auth_repository/src/mappers/session_mapper.dart';
import 'package:domain/domain.dart' as domain;
import 'package:m3t_api/m3t_api.dart' as api;

/// Data-layer implementation of [domain.EventsRepository].
final class EventsRepositoryImpl implements domain.EventsRepository {
  EventsRepositoryImpl({
    required api.M3tApiClient apiClient,
  }) : _apiClient = apiClient;

  final api.M3tApiClient _apiClient;

  @override
  Future<List<domain.Event>> getMyEvents() async {
    try {
      final events = await _apiClient.getMyEvents();
      return events.map((e) => e.toDomain()).toList();
    } on api.M3tApiException catch (error) {
      _throwEventsFailure(error);
    } on Object catch (_) {
      throw domain.EventsUnknownError();
    }
  }

  @override
  Future<domain.EventWithRooms> getEventById({
    required String eventID,
  }) async {
    try {
      final result = await _apiClient.getEventById(eventID: eventID);
      return result.toDomain();
    } on api.M3tApiException catch (error) {
      _throwEventsFailure(error);
    } on Object catch (_) {
      throw domain.EventsUnknownError();
    }
  }

  @override
  Future<({domain.EventCheckIn checkIn, bool alreadyCheckedIn})>
  checkInAttendee({
    required String eventID,
    required String userID,
  }) async {
    try {
      final result = await _apiClient.checkInAttendee(
        eventID: eventID,
        userID: userID,
      );
      return (
        checkIn: result.checkIn.toDomain(),
        alreadyCheckedIn: result.alreadyCheckedIn,
      );
    } on api.M3tApiException catch (error) {
      _throwEventsFailure(error);
    } on Object catch (_) {
      throw domain.EventsUnknownError();
    }
  }

  @override
  Future<List<domain.EventDeliverable>> getEventDeliverables({
    required String eventID,
  }) async {
    try {
      final list = await _apiClient.getEventDeliverables(eventID: eventID);
      return list.map((e) => e.toDomain()).toList();
    } on api.M3tApiException catch (error) {
      _throwEventsFailure(error);
    } on Object catch (_) {
      throw domain.EventsUnknownError();
    }
  }

  @override
  Future<domain.DeliverableGiveaway> giveDeliverableToUser({
    required String eventID,
    required String deliverableID,
    required String userID,
    bool giveAnyway = false,
  }) async {
    try {
      final result = await _apiClient.giveDeliverableToUser(
        eventID: eventID,
        deliverableID: deliverableID,
        userID: userID,
        giveAnyway: giveAnyway,
      );
      return result.toDomain();
    } on api.M3tApiException catch (error) {
      _throwEventsFailure(error);
    } on Object catch (_) {
      throw domain.EventsUnknownError();
    }
  }

  @override
  Future<({domain.SessionCheckIn checkIn, bool alreadyCheckedIn})>
  checkInAttendeeToSession({
    required String eventID,
    required String sessionID,
    required String userID,
  }) async {
    try {
      final result = await _apiClient.checkInAttendeeToSession(
        eventID: eventID,
        sessionID: sessionID,
        userID: userID,
      );
      return (
        checkIn: result.checkIn.toDomain(),
        alreadyCheckedIn: result.alreadyCheckedIn,
      );
    } on api.M3tApiException catch (error) {
      _throwEventsFailure(error);
    } on Object catch (_) {
      throw domain.EventsUnknownError();
    }
  }

  @override
  Future<domain.Session> getSessionById({
    required String sessionID,
  }) async {
    try {
      final session = await _apiClient.getSessionById(sessionID: sessionID);
      return session.toDomain();
    } on api.M3tApiException catch (error) {
      _throwEventsFailure(error);
    } on Object catch (_) {
      throw domain.EventsUnknownError();
    }
  }

  @override
  Future<domain.Session> updateSessionStatus({
    required String eventID,
    required String sessionID,
    required domain.SessionStatus status,
  }) async {
    try {
      final session = await _apiClient.updateSessionStatus(
        eventID: eventID,
        sessionID: sessionID,
        status: status.toApiValue(),
      );
      return session.toDomain();
    } on api.M3tApiException catch (error) {
      _throwEventsFailure(error);
    } on Object catch (_) {
      throw domain.EventsUnknownError();
    }
  }

  @override
  Future<int> releaseUncheckedInSessionBookings({
    required String eventID,
    required String sessionID,
  }) async {
    try {
      return await _apiClient.releaseUncheckedInSessionBookings(
        eventID: eventID,
        sessionID: sessionID,
      );
    } on api.M3tApiException catch (error) {
      _throwEventsFailure(error);
    } on Object catch (_) {
      throw domain.EventsUnknownError();
    }
  }
}

/// Maps every transport-layer [api.M3tApiException] to a domain
/// [domain.EventsFailure]. Branches on the backend business code first
/// (`error.code`) and falls back to HTTP status code when the code is
/// unknown or absent.
Never _throwEventsFailure(api.M3tApiException e) {
  switch (e.errorCode) {
    case 'session_full':
      throw domain.EventsSessionFull();
    case 'schedule_conflict':
      throw domain.EventsScheduleConflict();
    case 'live_session_conflict':
      throw domain.EventsLiveSessionConflict();
    case 'session_not_live':
      throw domain.EventsConflict();
    case 'deliverable_already_given':
      throw domain.EventsDeliverableAlreadyGiven();
    case 'unprocessable_entity':
      throw domain.EventsUnprocessableEntity();
    case 'not_registered_for_event':
      throw domain.EventsNotRegisteredForEvent();
    case 'session_all_attend':
      throw domain.EventsSessionAllAttend();
    case 'invalid_or_expired_token':
      throw domain.EventsInvalidOrExpiredToken();
    case 'event_not_found':
    case 'session_not_found':
    case 'deliverable_not_found':
      throw domain.EventsNotFound();
    case 'conflict':
      throw domain.EventsConflict();
    case 'unauthorized':
      throw domain.EventsUnauthorized();
    case 'tier_not_allowed':
    case 'not_event_owner':
    case 'not_event_team_member':
      throw domain.EventsForbidden();
    case 'missing_path_param':
    case 'invalid_path_param':
    case 'invalid_query_param':
    case 'invalid_request_body':
      throw domain.EventsInvalidInput();
    case 'internal_error':
      throw domain.EventsUnknownError();
  }
  switch (e.statusCode) {
    case 400:
      throw domain.EventsInvalidInput();
    case 401:
      throw domain.EventsUnauthorized();
    case 403:
      throw domain.EventsForbidden();
    case 404:
      throw domain.EventsNotFound();
    case 409:
      throw domain.EventsConflict();
    case 422:
      throw domain.EventsUnprocessableEntity();
    case 500:
      throw domain.EventsUnknownError();
  }
  throw domain.EventsNetworkError();
}
