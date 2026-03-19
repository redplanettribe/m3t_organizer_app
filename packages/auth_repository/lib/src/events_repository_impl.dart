import 'package:auth_repository/src/mappers/event_check_in_mapper.dart';
import 'package:auth_repository/src/mappers/event_mapper.dart';
import 'package:auth_repository/src/mappers/get_event_by_id_response_mapper.dart';
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
    } on api.GetMyEventsFailure catch (_) {
      throw domain.EventsNetworkError();
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
    } on api.GetEventByIdFailure catch (error) {
      switch (error.statusCode) {
        case 400:
          throw domain.EventsInvalidInput();
        case 401:
          throw domain.EventsUnauthorized();
        case 403:
          throw domain.EventsForbidden();
        case 404:
          throw domain.EventsNotFound();
        default:
          throw domain.EventsNetworkError();
      }
    } on Object catch (_) {
      throw domain.EventsUnknownError();
    }
  }

  @override
  Future<domain.EventCheckIn> checkInAttendee({
    required String eventID,
    required String userID,
  }) async {
    try {
      final checkIn = await _apiClient.checkInAttendee(
        eventID: eventID,
        userID: userID,
      );
      return checkIn.toDomain();
    } on api.CheckInAttendeeFailure catch (error) {
      switch (error.statusCode) {
        case 400:
          throw domain.EventsInvalidInput();
        case 401:
          throw domain.EventsUnauthorized();
        case 403:
          throw domain.EventsForbidden();
        case 404:
          throw domain.EventsNotFound();
        default:
          throw domain.EventsNetworkError();
      }
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
    } on api.GetSessionByIdFailure catch (error) {
      switch (error.statusCode) {
        case 400:
          throw domain.EventsInvalidInput();
        case 401:
          throw domain.EventsUnauthorized();
        case 403:
          throw domain.EventsForbidden();
        case 404:
          throw domain.EventsNotFound();
        default:
          throw domain.EventsNetworkError();
      }
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
    } on api.UpdateSessionStatusFailure catch (error) {
      switch (error.statusCode) {
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
        default:
          throw domain.EventsNetworkError();
      }
    } on Object catch (_) {
      throw domain.EventsUnknownError();
    }
  }
}

//
