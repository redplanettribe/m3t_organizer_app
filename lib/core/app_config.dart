/// Compile-time configuration injected via `--dart-define`.
///
/// Usage:
/// ```sh
/// fvm flutter run --dart-define=M3T_API_URL=https://api.example.com
/// fvm flutter build apk --dart-define=M3T_API_URL=https://api.example.com
/// fvm flutter build ios --dart-define=M3T_API_URL=https://api.example.com
/// ```
abstract final class AppConfig {
  /// Android emulator loopback for local backend development.
  static const defaultAndroidEmulatorApiBaseUrl = 'http://10.0.2.2:8080';

  /// Desktop / iOS simulator default for local backend development.
  static const defaultDesktopApiBaseUrl = 'http://127.0.0.1:8080';

  /// The base URL for the m3t backend API.
  ///
  /// Prefer resolving in bootstrap so desktop targets localhost while Android
  /// keeps the emulator loopback default. This getter remains for helpers that
  /// only need a compile-time fallback.
  static const baseUrl = String.fromEnvironment(
    'M3T_API_URL',
    defaultValue: defaultAndroidEmulatorApiBaseUrl,
  );

  /// Android emulator loopback for local object store development.
  static const defaultAndroidEmulatorObjectStoreUrl = 'http://10.0.2.2:9000';

  /// Desktop / iOS simulator default for local object store development.
  static const defaultDesktopObjectStoreUrl = 'http://127.0.0.1:9000';

  /// The base URL for the object store (MinIO/S3) used when presigned upload
  /// URLs point at **localhost** (local dev). The client rewrites only those
  /// URLs so the Android emulator can reach the host via `10.0.2.2`.
  ///
  /// Presigned URLs with a public hostname (e.g. Cloudflare R2) are never
  /// rewritten, so physical devices and production builds work without changes.
  static const objectStoreUrl = String.fromEnvironment(
    'OBJECT_STORE_URL',
    defaultValue: defaultAndroidEmulatorObjectStoreUrl,
  );
}
