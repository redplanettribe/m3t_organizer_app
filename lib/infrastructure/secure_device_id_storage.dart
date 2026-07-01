import 'package:auth_repository/auth_repository.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

/// [DeviceIdStorage] backed by [FlutterSecureStorage].
final class SecureDeviceIdStorage implements DeviceIdStorage {
  const SecureDeviceIdStorage({
    FlutterSecureStorage? storage,
    Uuid? uuid,
  }) : _storage = storage ?? const FlutterSecureStorage(),
       _uuid = uuid ?? const Uuid();

  static const _deviceIdKey = 'push_device_id';

  final FlutterSecureStorage _storage;
  final Uuid _uuid;

  @override
  Future<String> readOrCreate() async {
    final existing = await _storage.read(key: _deviceIdKey);
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }

    final deviceId = _uuid.v4();
    await _storage.write(key: _deviceIdKey, value: deviceId);
    return deviceId;
  }
}
