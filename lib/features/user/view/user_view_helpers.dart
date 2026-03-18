import 'package:domain/domain.dart';
import 'package:m3t_organizer/core/media/media_url_resolver.dart';

/// User display utilities derived directly from domain data.
extension UserDisplayExtension on AuthUser? {
  /// Profile picture URL resolved for the current app runtime.
  String? get resolvedProfilePictureUrl =>
      MediaUrlResolver.resolveAppUrl(this?.profilePictureUrl);

  /// Full display name built from available name parts.
  ///
  /// Joins [AuthUser.name] and [AuthUser.lastName] with a single space,
  /// skipping whichever parts are null or blank. Returns `null` when
  /// neither is available so callers can guard the UI cleanly.
  String? get displayName {
    final user = this;
    if (user == null) return null;
    final parts = [
      user.name?.trim(),
      user.lastName?.trim(),
    ].whereType<String>().where((s) => s.isNotEmpty);
    return parts.isEmpty ? null : parts.join(' ');
  }

  /// Up-to-two-character initials for display in avatars.
  ///
  /// Priority: first + last name -> first name alone -> email local-part.
  /// Returns `'?'` when no data is available.
  String get initials {
    final user = this;
    if (user == null) return '?';
    final name = user.name?.trim();
    final lastName = user.lastName?.trim();
    if (name != null &&
        name.isNotEmpty &&
        lastName != null &&
        lastName.isNotEmpty) {
      return '${name[0]}${lastName[0]}'.toUpperCase();
    }
    if (name != null && name.isNotEmpty) {
      return name.length >= 2
          ? name.substring(0, 2).toUpperCase()
          : name[0].toUpperCase();
    }
    final email = user.email.trim();
    if (email.isNotEmpty) {
      final part = email.split('@').first;
      return part.length >= 2
          ? part.substring(0, 2).toUpperCase()
          : part[0].toUpperCase();
    }
    return '?';
  }
}
