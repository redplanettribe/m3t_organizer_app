import 'package:domain/src/entities/event.dart';
import 'package:domain/src/entities/event_check_in.dart';
import 'package:domain/src/entities/event_with_rooms.dart';

/// Repository interface for events-related operations.
abstract interface class EventsRepository {
  Future<List<Event>> getMyEvents();

  Future<EventWithRooms> getEventById({required String eventID});

  Future<EventCheckIn> checkInAttendee({
    required String eventID,
    required String userID,
  });
}

//
