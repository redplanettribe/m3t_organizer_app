import 'package:domain/src/entities/event.dart';

/// Repository interface for fetching the current user's managed events.
// ignore: one_member_abstracts
abstract interface class EventsRepository {
  Future<List<Event>> getMyEvents();
}

//
