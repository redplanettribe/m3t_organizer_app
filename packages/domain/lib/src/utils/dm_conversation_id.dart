/// Deterministic DM thread id: `dm:{event_id}:{min_uuid}:{max_uuid}`.
String dmConversationId({
  required String eventId,
  required String userIdA,
  required String userIdB,
}) {
  final eventLower = eventId.toLowerCase();
  final a = userIdA.toLowerCase();
  final b = userIdB.toLowerCase();
  final min = a.compareTo(b) <= 0 ? a : b;
  final max = a.compareTo(b) <= 0 ? b : a;
  return 'dm:$eventLower:$min:$max';
}
