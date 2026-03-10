import 'package:domain/src/entities/managed_event.dart';
import 'package:domain/src/failures/get_my_managed_events_failure.dart';

/// Repository for event management (e.g. events the user owns or is a team
/// member of).
// ignore: one_member_abstracts
abstract interface class EventsRepository {
  /// Returns events where the current user is the owner or a team member.
  ///
  /// Throws [GetMyManagedEventsFailure] on error.
  Future<List<ManagedEventEntity>> getMyManagedEvents();
}
