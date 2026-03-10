import 'package:domain/domain.dart';
import 'package:m3t_api/m3t_api.dart' as m3t;

final class EventsRepositoryImpl implements EventsRepository {
  EventsRepositoryImpl({required m3t.M3tApiClient apiClient})
      : _apiClient = apiClient;

  final m3t.M3tApiClient _apiClient;

  @override
  Future<List<ManagedEventEntity>> getMyManagedEvents() async {
    try {
      final events = await _apiClient.getMyManagedEvents();
      return events
          .map(
            (e) => ManagedEventEntity(
              eventId: e.id,
              name: e.name,
              description: e.description,
              eventCode: e.eventCode,
              startDate: e.startDate,
              durationDays: e.durationDays,
              thumbnailUrl: e.thumbnailUrl,
            ),
          )
          .toList();
    } on m3t.GetMyManagedEventsFailure catch (e) {
      if (e.statusCode == 401 || e.errorCode == 'unauthorized') {
        throw GetMyManagedEventsUnauthorized();
      }
      if (e.statusCode != null && e.statusCode! >= 500) {
        throw GetMyManagedEventsUnknown();
      }
      throw GetMyManagedEventsNetworkError();
    } on Exception catch (_) {
      throw GetMyManagedEventsNetworkError();
    }
  }
}
