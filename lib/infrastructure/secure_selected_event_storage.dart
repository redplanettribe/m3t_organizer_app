import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:m3t_organizer/features/event_selector/data/selected_event_storage.dart';

/// [SelectedEventStorage] adapter backed by [FlutterSecureStorage].
final class SecureSelectedEventStorage implements SelectedEventStorage {
  const SecureSelectedEventStorage({
    FlutterSecureStorage? storage,
  }) : _storage = storage ?? const FlutterSecureStorage();

  static const _selectedEventKey = 'selected_event_id';

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read() => _storage.read(key: _selectedEventKey);

  @override
  Future<void> write(String eventID) =>
      _storage.write(key: _selectedEventKey, value: eventID);

  @override
  Future<void> clear() => _storage.delete(key: _selectedEventKey);
}
