import 'package:m3t_api/src/exceptions.dart';
import 'package:m3t_api/src/http/api_http_executor.dart';
import 'package:m3t_api/src/http/api_paths.dart';
import 'package:m3t_api/src/models/api_error.dart';
import 'package:m3t_api/src/models/event.dart';

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
}

//
