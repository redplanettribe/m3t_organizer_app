/// Session lifecycle status.
///
/// Matches backend values from Swagger:
/// `Scheduled`, `Live`, `Completed`, `Draft`, `Canceled`.
enum SessionStatus {
  scheduled,
  live,
  completed,
  draft,
  canceled,
}

/// String parsing/formatting helpers for [SessionStatus].
extension SessionStatusX on SessionStatus {
  /// Backend representation uses PascalCase.
  String toApiValue() => switch (this) {
    SessionStatus.scheduled => 'Scheduled',
    SessionStatus.live => 'Live',
    SessionStatus.completed => 'Completed',
    SessionStatus.draft => 'Draft',
    SessionStatus.canceled => 'Canceled',
  };
}

/// Parses backend `SessionStatus` values (PascalCase) into domain enum values.
SessionStatus sessionStatusFromApiValue(String value) {
  return switch (value) {
    'Scheduled' => SessionStatus.scheduled,
    'Live' => SessionStatus.live,
    'Completed' => SessionStatus.completed,
    'Draft' => SessionStatus.draft,
    'Canceled' => SessionStatus.canceled,
    _ => throw ArgumentError.value(value, 'value', 'Unknown status'),
  };
}
