import 'package:go_router/go_router.dart' show GoRoute;

/// Centralized route-path constants.
///
/// Every navigation call in the app must reference a constant here — never a
/// raw string literal.
///
/// - Full paths (prefixed with `/`) are used for programmatic navigation:
///   `context.push(AppRoutes.updateUser)`.
/// - Segment constants (no `/`) are used in nested [GoRoute] `path` fields.
abstract final class AppRoutes {
  /// Full absolute paths — used for navigation calls.
  static const login = '/login';
  static const home = '/';
  static const config = '/config';
  static const updateUser = '/config/update-user';
  static const event = '/events/:eventID';

  /// Bare path segments — used in nested [GoRoute] definitions only.
  static const updateUserSegment = 'update-user';

  /// Builds the event route path for a specific event ID.
  static String eventById(String eventID) => '/events/$eventID';
}
