import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart' show LaunchMode, launchUrl;

final class SpeakerDetailPage extends StatelessWidget {
  const SpeakerDetailPage({required this.speaker, super.key});

  final Speaker speaker;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fullName = _speakerFullName(speaker);
    final tagline = _normalizedText(speaker.tagLine);
    final bio = _normalizedText(speaker.bio);
    final phone = _normalizedText(speaker.phoneNumber);

    return Scaffold(
      appBar: AppBar(title: Text(fullName)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: _SpeakerAvatar(
                imageUrl: speaker.profilePicture,
                initials: _speakerInitials(speaker),
                radius: 52,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                fullName,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (speaker.isTopSpeaker) ...[
              const SizedBox(height: 10),
              const Center(
                child: Chip(
                  avatar: Icon(Icons.star_rounded, size: 18),
                  label: Text('Top Speaker'),
                ),
              ),
            ],
            if (tagline != null) ...[
              const SizedBox(height: 20),
              Text(
                tagline,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            if (bio != null) ...[
              const SizedBox(height: 16),
              Text(bio, style: theme.textTheme.bodyMedium),
            ],
            if (phone != null) ...[
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    Icons.phone_rounded,
                    size: 20,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    phone,
                    style: theme.textTheme.bodyLarge,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => _openWhatsApp(phone),
                  icon: const Icon(Icons.chat_rounded),
                  label: const Text('Message on WhatsApp'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

Future<void> _openWhatsApp(String rawPhone) async {
  final digits = rawPhone.replaceAll(RegExp(r'[^\d]'), '');
  final uri = Uri.parse('https://wa.me/$digits');
  try {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {
    await launchUrl(uri, mode: LaunchMode.platformDefault);
  }
}

final class _SpeakerAvatar extends StatelessWidget {
  const _SpeakerAvatar({
    required this.imageUrl,
    required this.initials,
    required this.radius,
  });

  final String? imageUrl;
  final String initials;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final normalizedUrl = _normalizedText(imageUrl);
    final diameter = radius * 2;

    return CircleAvatar(
      radius: radius,
      backgroundColor: theme.colorScheme.primaryContainer,
      child: ClipOval(
        child: normalizedUrl != null
            ? Image.network(
                normalizedUrl,
                width: diameter,
                height: diameter,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _SpeakerAvatarInitials(
                  initials: initials,
                  radius: radius,
                ),
              )
            : _SpeakerAvatarInitials(initials: initials, radius: radius),
      ),
    );
  }
}

final class _SpeakerAvatarInitials extends StatelessWidget {
  const _SpeakerAvatarInitials({
    required this.initials,
    required this.radius,
  });

  final String initials;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: radius * 2,
      height: radius * 2,
      child: Center(
        child: Text(
          initials,
          style: theme.textTheme.headlineMedium?.copyWith(
            color: theme.colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

String _speakerFullName(Speaker speaker) =>
    '${speaker.firstName} ${speaker.lastName}'.trim();

String _speakerInitials(Speaker speaker) {
  final first = speaker.firstName.trim();
  final last = speaker.lastName.trim();

  final firstInitial = first.isNotEmpty ? first.characters.first : '';
  final lastInitial = last.isNotEmpty ? last.characters.first : '';
  final initials = '$firstInitial$lastInitial'.trim();

  return initials.isEmpty ? '?' : initials.toUpperCase();
}

String? _normalizedText(String? value) {
  if (value == null) return null;
  final trimmed = value.trim();
  if (trimmed.isEmpty) return null;
  return trimmed;
}
