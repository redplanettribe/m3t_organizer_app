import 'package:domain/src/entities/deliverable_giveaway.dart';
import 'package:domain/src/entities/event.dart';
import 'package:domain/src/entities/event_check_in.dart';
import 'package:domain/src/entities/event_deliverable.dart';
import 'package:domain/src/entities/event_with_rooms.dart';
import 'package:domain/src/entities/session.dart';
import 'package:domain/src/entities/session_check_in.dart';
import 'package:domain/src/enums/session_status.dart';

/// Repository interface for events-related operations.
abstract interface class EventsRepository {
  Future<List<Event>> getMyEvents();

  Future<EventWithRooms> getEventById({required String eventID});

  Future<EventCheckIn> checkInAttendee({
    required String eventID,
    required String userID,
  });

  Future<List<EventDeliverable>> getEventDeliverables({
    required String eventID,
  });

  Future<DeliverableGiveaway> giveDeliverableToUser({
    required String eventID,
    required String deliverableID,
    required String userID,
    bool giveAnyway = false,
  });

  Future<SessionCheckIn> checkInAttendeeToSession({
    required String eventID,
    required String sessionID,
    required String userID,
  });

  /// Releases all bookings for attendees who haven't checked in to the
  /// given live session.
  ///
  /// Returns the number of bookings released.
  Future<int> releaseUncheckedInSessionBookings({
    required String eventID,
    required String sessionID,
  });

  Future<Session> getSessionById({required String sessionID});

  Future<Session> updateSessionStatus({
    required String eventID,
    required String sessionID,
    required SessionStatus status,
  });
}

//
