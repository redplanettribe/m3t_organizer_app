import 'dart:convert';

import 'package:m3t_api/src/exceptions.dart';
import 'package:m3t_api/src/http/api_http_executor.dart';
import 'package:m3t_api/src/http/api_paths.dart';
import 'package:m3t_api/src/models/agenda_ws_ticket.dart';
import 'package:m3t_api/src/models/deliverable_giveaway.dart';
import 'package:m3t_api/src/models/event.dart';
import 'package:m3t_api/src/models/event_check_in.dart';
import 'package:m3t_api/src/models/event_deliverable.dart';
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

    final items = _executor.parseListEnvelope(
      response,
      onError:
          ({
            required message,
            required statusCode,
            errorCode,
            showToUser = false,
          }) => GetMyEventsFailure(
            message,
            statusCode: statusCode,
            errorCode: errorCode,
            showToUser: showToUser,
          ),
      itemKeys: const ['events'],
    );

    return items.map(Event.fromJson).toList();
  }

  /// Returns a single event with its nested rooms and sessions.
  Future<GetEventByIdResponse> getEventById({
    required String eventID,
  }) async {
    final response = await _executor.client.get(
      _executor.uri(EventPaths.byId(eventID)),
      headers: await _executor.authHeaders(),
    );

    final data = _executor.parseEnvelope(
      response,
      onError:
          ({
            required message,
            required statusCode,
            errorCode,
            showToUser = false,
          }) => GetEventByIdFailure(
            message,
            statusCode: statusCode,
            errorCode: errorCode,
            showToUser: showToUser,
          ),
    );

    if (data == null) {
      throw GetEventByIdFailure(
        'Missing data field in response',
        statusCode: response.statusCode,
      );
    }

    return GetEventByIdResponse.fromJson(data);
  }

  /// Records check-in of an attendee for the given event.
  ///
  /// Returns the created or existing [EventCheckIn] record alongside an
  /// `alreadyCheckedIn` flag derived from the HTTP status (`200` means the
  /// attendee was already checked in, `201` means a new check-in was created).
  Future<({EventCheckIn checkIn, bool alreadyCheckedIn})> checkInAttendee({
    required String eventID,
    required String userID,
  }) async {
    final response = await _executor.client.post(
      _executor.uri(EventPaths.checkIns(eventID)),
      headers: await _executor.authHeaders(),
      body: jsonEncode(<String, String>{'user_id': userID}),
    );

    final data = _executor.parseEnvelope(
      response,
      onError:
          ({
            required message,
            required statusCode,
            errorCode,
            showToUser = false,
          }) => CheckInAttendeeFailure(
            message,
            statusCode: statusCode,
            errorCode: errorCode,
            showToUser: showToUser,
          ),
    );

    if (data == null) {
      throw CheckInAttendeeFailure(
        'Missing data field in response',
        statusCode: response.statusCode,
      );
    }

    return (
      checkIn: EventCheckIn.fromJson(data),
      alreadyCheckedIn: response.statusCode == 200,
    );
  }

  /// Returns deliverables configured for the event.
  Future<List<EventDeliverable>> getEventDeliverables({
    required String eventID,
  }) async {
    final response = await _executor.client.get(
      _executor.uri(EventPaths.deliverables(eventID)),
      headers: await _executor.authHeaders(),
    );

    final items = _executor.parseListEnvelope(
      response,
      onError:
          ({
            required message,
            required statusCode,
            errorCode,
            showToUser = false,
          }) => GetEventDeliverablesFailure(
            message,
            statusCode: statusCode,
            errorCode: errorCode,
            showToUser: showToUser,
          ),
      itemKeys: const ['deliverables'],
    );

    return items.map(EventDeliverable.fromJson).toList();
  }

  /// Records giving a deliverable to the user identified by [userID].
  Future<DeliverableGiveaway> giveDeliverableToUser({
    required String eventID,
    required String deliverableID,
    required String userID,
    bool giveAnyway = false,
  }) async {
    final response = await _executor.client.post(
      _executor.uri(
        EventPaths.deliverableGiveaways(
          eventID: eventID,
          deliverableID: deliverableID,
        ),
      ),
      headers: await _executor.authHeaders(),
      body: jsonEncode(<String, dynamic>{
        'user_id': userID,
        if (giveAnyway) 'give_anyway': true,
      }),
    );

    final data = _executor.parseEnvelope(
      response,
      onError:
          ({
            required message,
            required statusCode,
            errorCode,
            showToUser = false,
          }) => GiveDeliverableFailure(
            message,
            statusCode: statusCode,
            errorCode: errorCode,
            showToUser: showToUser,
          ),
    );

    if (data == null) {
      throw GiveDeliverableFailure(
        'Missing data field in response',
        statusCode: response.statusCode,
      );
    }

    return DeliverableGiveaway.fromJson(data);
  }

  /// Records check-in of an attendee for a specific session in an event.
  ///
  /// Returns the created or existing [SessionCheckIn] record alongside an
  /// `alreadyCheckedIn` flag derived from the HTTP status (`200` means the
  /// attendee was already checked in to this session, `201` means a new
  /// check-in was created).
  Future<({SessionCheckIn checkIn, bool alreadyCheckedIn})>
  checkInAttendeeToSession({
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

    final data = _executor.parseEnvelope(
      response,
      onError:
          ({
            required message,
            required statusCode,
            errorCode,
            showToUser = false,
          }) => CheckInAttendeeToSessionFailure(
            message,
            statusCode: statusCode,
            errorCode: errorCode,
            showToUser: showToUser,
          ),
    );

    if (data == null) {
      throw CheckInAttendeeToSessionFailure(
        'Missing data field in response',
        statusCode: response.statusCode,
      );
    }

    return (
      checkIn: SessionCheckIn.fromJson(data),
      alreadyCheckedIn: response.statusCode == 200,
    );
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

    final data = _executor.parseEnvelope(
      response,
      onError:
          ({
            required message,
            required statusCode,
            errorCode,
            showToUser = false,
          }) => ReleaseSessionBookingsFailure(
            message,
            statusCode: statusCode,
            errorCode: errorCode,
            showToUser: showToUser,
          ),
    );

    if (data == null) {
      throw ReleaseSessionBookingsFailure(
        'Missing data field in response',
        statusCode: response.statusCode,
      );
    }

    final releasedValue = data['released'];
    if (releasedValue is! num) {
      throw ReleaseSessionBookingsFailure(
        'Missing or invalid released field in response',
        statusCode: response.statusCode,
      );
    }

    return releasedValue.toInt();
  }

  /// Short-lived JWT for `GET /ws?ticket=…` (organizer agenda).
  Future<AgendaWsTicket> getOrganizerAgendaWebSocketTicket({
    required String eventID,
  }) async {
    final response = await _executor.client.post(
      _executor.uri(EventPaths.agendaWebSocketTicket(eventID)),
      headers: await _executor.authHeaders(),
      body: jsonEncode(<String, dynamic>{}),
    );

    final data = _executor.parseEnvelope(
      response,
      onError:
          ({
            required message,
            required statusCode,
            errorCode,
            showToUser = false,
          }) => GetOrganizerAgendaWsTicketFailure(
            message,
            statusCode: statusCode,
            errorCode: errorCode,
            showToUser: showToUser,
          ),
    );

    if (data == null) {
      throw GetOrganizerAgendaWsTicketFailure(
        'Missing data field in response',
        statusCode: response.statusCode,
      );
    }

    return AgendaWsTicket.fromJson(data);
  }
}
