/// Persists a stable per-install device identifier for push token registration.
// ignore: one_member_abstracts
abstract interface class DeviceIdStorage {
  /// Returns an existing ID or creates and stores a new one.
  Future<String> readOrCreate();
}
