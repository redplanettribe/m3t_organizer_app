/// Persists the user's last-selected event id across app launches.
abstract interface class SelectedEventStorage {
  Future<String?> read();

  Future<void> write(String eventID);

  Future<void> clear();
}
