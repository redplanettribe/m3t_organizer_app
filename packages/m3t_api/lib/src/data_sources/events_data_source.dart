import 'dart:convert';

import 'package:m3t_api/src/exceptions.dart';
import 'package:m3t_api/src/http/api_http_executor.dart';
import 'package:m3t_api/src/http/api_paths.dart';
import 'package:m3t_api/src/models/api_error.dart';
import 'package:m3t_api/src/models/event.dart';
import 'package:m3t_api/src/models/event_check_in.dart';
import 'package:m3t_api/src/models/get_event_by_id_response.dart';
import 'package:m3t_api/src/models/session_check_in.dart';

/// Handles all events API calls.
final class EventsDataSource {
  const EventsDataSource({required ApiHttpExecutor executor})
    : _executor = executor;

  final ApiHttpExecutor _executor;

  /// Returns events where the authenticated user is the owner or a team
  /// member (managed events).
  Future<List<Event>> getMyEvents() async {
    final response = await _executor.client.get(
      _executor.uri(EventPaths.me),
      headers: await _executor.authHeaders(),
    );

    if (response.statusCode != 200) {
      throw GetMyEventsFailure(
        'Request failed with status ${response.statusCode}',
      );
    }

    final body = _executor.decodeJson(response.body);
    final errorJson = body['error'] as Map<String, dynamic>?;
    if (errorJson != null) {
      final error = ApiError.fromJson(errorJson);
      throw GetMyEventsFailure(error.message);
    }

    final dataJson = body['data'] as List<dynamic>?;
    if (dataJson == null) {
      throw GetMyEventsFailure('Missing data field in response');
    }

    return dataJson
        .map((e) => Event.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Returns a single event with its nested rooms and sessions.
  Future<GetEventByIdResponse> getEventById({
    required String eventID,
  }) async {
    final response = await _executor.client.get(
      _executor.uri(EventPaths.byId(eventID)),
      headers: await _executor.authHeaders(),
    );

    if (response.statusCode != 200) {
      throw GetEventByIdFailure(
        'Request failed with status ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }

    final body = _executor.decodeJson(response.body);
    final errorJson = body['error'] as Map<String, dynamic>?;
    if (errorJson != null) {
      final error = ApiError.fromJson(errorJson);
      throw GetEventByIdFailure(
        error.message,
        statusCode: response.statusCode,
        errorCode: error.code,
      );
    }

    final dataJson = body['data'] as Map<String, dynamic>?;
    if (dataJson == null) {
      throw GetEventByIdFailure(
        'Missing data field in response',
        statusCode: response.statusCode,
      );
    }

    return GetEventByIdResponse.fromJson(dataJson);
  }

  /// Records check-in of an attendee for the given event.
  ///
  /// Returns the created or existing [EventCheckIn] record.
  Future<EventCheckIn> checkInAttendee({
    required String eventID,
    required String userID,
  }) async {
    final response = await _executor.client.post(
      _executor.uri(EventPaths.checkIns(eventID)),
      headers: await _executor.authHeaders(),
      body: jsonEncode(<String, String>{'user_id': userID}),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw CheckInAttendeeFailure(
        'Request failed with status ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }

    final body = _executor.decodeJson(response.body);
    final errorJson = body['error'] as Map<String, dynamic>?;
    if (errorJson != null) {
      final error = ApiError.fromJson(errorJson);
      throw CheckInAttendeeFailure(
        error.message,
        statusCode: response.statusCode,
        errorCode: error.code,
      );
    }

    final dataJson = body['data'] as Map<String, dynamic>?;
    if (dataJson == null) {
      throw CheckInAttendeeFailure(
        'Missing data field in response',
        statusCode: response.statusCode,
      );
    }

    return EventCheckIn.fromJson(dataJson);
  }

  /// Records check-in of an attendee for a specific session in an event.
  Future<SessionCheckIn> checkInAttendeeToSession({
    required String eventID,
    required String sessionID,
    required String userID,
  }) async {
    final response = await _executor.client.post(
      _executor.uri(
        SessionPaths.checkIns(
          eventID: eventID,
          sessionID: sessionID,
        ),
      ),
      headers: await _executor.authHeaders(),
      body: jsonEncode(<String, String>{'user_id': userID}),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw CheckInAttendeeToSessionFailure(
        'Request failed with status ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }

    final body = _executor.decodeJson(response.body);
    final errorJson = body['error'] as Map<String, dynamic>?;
    if (errorJson != null) {
      final error = ApiError.fromJson(errorJson);
      throw CheckInAttendeeToSessionFailure(
        error.message,
        statusCode: response.statusCode,
        errorCode: error.code,
      );
    }

    final dataJson = body['data'] as Map<String, dynamic>?;
    if (dataJson == null) {
      throw CheckInAttendeeToSessionFailure(
        'Missing data field in response',
        statusCode: response.statusCode,
      );
    }

    return SessionCheckIn.fromJson(dataJson);
  }

  /// Releases all bookings for attendees who haven't checked in to the
  /// given session.
  ///
  /// Returns the number of bookings released.
  Future<int> releaseUncheckedInSessionBookings({
    required String eventID,
    required String sessionID,
  }) async {
    final response = await _executor.client.delete(
      _executor.uri(
        SessionPaths.releaseUncheckedInSessionBookings(
          eventID: eventID,
          sessionID: sessionID,
        ),
      ),
      headers: await _executor.authHeaders(),
    );

    if (response.statusCode != 200) {
      throw ReleaseSessionBookingsFailure(
        'Request failed with status ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }

    final body = _executor.decodeJson(response.body);
    final errorJson = body['error'] as Map<String, dynamic>?;
    if (errorJson != null) {
      final error = ApiError.fromJson(errorJson);
      throw ReleaseSessionBookingsFailure(
        error.message,
        statusCode: response.statusCode,
        errorCode: error.code,
      );
    }

    final dataJson = body['data'] as Map<String, dynamic>?;
    if (dataJson == null) {
      throw ReleaseSessionBookingsFailure(
        'Missing data field in response',
        statusCode: response.statusCode,
      );
    }

    final releasedValue = dataJson['released'];
    if (releasedValue is! num) {
      throw ReleaseSessionBookingsFailure(
        'Missing or invalid released field in response',
        statusCode: response.statusCode,
      );
    }

    return releasedValue.toInt();
  }
}

//
