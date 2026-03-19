import 'package:domain/src/entities/event.dart';
import 'package:domain/src/entities/event_check_in.dart';

/// Repository interface for events-related operations.
abstract interface class EventsRepository {
  Future<List<Event>> getMyEvents();

  Future<EventCheckIn> checkInAttendee({
    required String eventID,
    required String userID,
  });
}

//
