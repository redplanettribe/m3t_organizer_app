import 'dart:async' show unawaited;

import 'package:domain/domain.dart';
import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:m3t_organizer/app/routes.dart';
import 'package:m3t_organizer/features/session_status/bloc/session_status_cubit.dart';

final class SelectedSessionPanel extends StatelessWidget {
  const SelectedSessionPanel({
    required this.eventID,
    required this.roomName,
    required this.session,
    super.key,
  });

  final String eventID;
  final String roomName;
  final Session session;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SessionStatusCubit, SessionStatusState>(
      listenWhen: (previous, current) =>
          previous.errorMessage != current.errorMessage &&
          current.errorMessage != null &&
          !current.loading,
      listener: (context, state) {
        final message = _friendlyErrorMessage(state.errorMessage!);
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(message),
              behavior: SnackBarBehavior.floating,
            ),
          );
      },
      builder: (context, state) {
        final activeSession = state.session ?? session;
        final activeStatus = activeSession.status;
        final timeLabel = _formatRange(
          activeSession.startTime,
          activeSession.endTime,
        );
        final subtitle =
            'Day ${activeSession.eventDay} • $timeLabel • '
            '$roomName';

        // Parent [SessionsView] owns scrolling — no nested scroll here.
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              subtitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (activeStatus != null)
                            _SessionStatusChip(status: activeStatus)
                          else
                            Chip(
                              label: const Text('Unknown'),
                              avatar: Icon(
                                Icons.help_outline_rounded,
                                size: 18,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 10),
                      _SessionTagsSection(tags: activeSession.tags),
                      const SizedBox(height: 12),
                      _SessionSpeakersSection(
                        speakers: activeSession.speakers,
                      ),
                      const SizedBox(height: 12),
                      const Divider(height: 1),
                      const SizedBox(height: 12),

                      Text(
                        'Session status',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),

                      if (state.loading && state.session == null)
                        const LinearProgressIndicator()
                      else
                        _StatusDropdown(
                          status: activeStatus,
                          updating: state.updating,
                          onChanged: (newStatus) {
                            if (newStatus == null) return;
                            unawaited(
                              context.read<SessionStatusCubit>().changeStatus(
                                newStatus,
                              ),
                            );
                          },
                        ),

                      if (state.updating) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Updating status...',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],

                      if (state.errorMessage != null &&
                          state.session == null) ...[
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: () => context
                              .read<SessionStatusCubit>()
                              .loadUnawaited(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

final class _StatusDropdown extends StatelessWidget {
  const _StatusDropdown({
    required this.status,
    required this.updating,
    required this.onChanged,
  });

  final SessionStatus? status;
  final bool updating;
  final ValueChanged<SessionStatus?> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (status == null) {
      return Text(
        'Status is not available yet.',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    }

    return DropdownButton<SessionStatus>(
      value: status,
      isExpanded: true,
      onChanged: updating ? null : onChanged,
      items:
          const [
            SessionStatus.scheduled,
            SessionStatus.live,
            SessionStatus.completed,
            SessionStatus.draft,
            SessionStatus.canceled,
          ].map(
            (s) {
              final label = _statusLabel(s);
              return DropdownMenuItem<SessionStatus>(
                value: s,
                child: Text(label),
              );
            },
          ).toList(),
    );
  }
}

final class _SessionTagsSection extends StatelessWidget {
  const _SessionTagsSection({
    required this.tags,
  });

  final List<Tag> tags;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tags',
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        if (tags.isEmpty)
          Text(
            'No tags',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final tag in tags)
                Chip(
                  visualDensity: VisualDensity.compact,
                  avatar: const Icon(Icons.tag_rounded, size: 16),
                  label: Text(tag.name),
                ),
            ],
          ),
      ],
    );
  }
}

final class _SessionSpeakersSection extends StatelessWidget {
  const _SessionSpeakersSection({
    required this.speakers,
  });

  final List<Speaker> speakers;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Speakers',
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        if (speakers.isEmpty)
          Text(
            'No speakers',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final speaker in speakers)
                ActionChip(
                  visualDensity: VisualDensity.compact,
                  onPressed: () => context.push(
                    AppRoutes.speakerById(speaker.id),
                    extra: speaker,
                  ),
                  avatar: _SpeakerAvatar(
                    imageUrl: speaker.profilePicture,
                    initials: _speakerInitials(speaker),
                    radius: 10,
                  ),
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_speakerFullName(speaker)),
                      if (speaker.isTopSpeaker) ...[
                        const SizedBox(width: 6),
                        const Icon(Icons.star_rounded, size: 16),
                      ],
                    ],
                  ),
                ),
            ],
          ),
      ],
    );
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
                errorBuilder: (context, error, stackTrace) {
                  if (kDebugMode) {
                    debugPrint(
                      'SelectedSessionPanel: speaker avatar failed '
                      'url=$normalizedUrl error=$error',
                    );
                    debugPrint('SelectedSessionPanel: stack $stackTrace');
                  }
                  return _SpeakerAvatarInitials(
                    initials: initials,
                    radius: radius,
                  );
                },
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
          style:
              (radius >= 24
                      ? theme.textTheme.titleMedium
                      : theme.textTheme.labelMedium)
                  ?.copyWith(
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

final class _SessionStatusChip extends StatelessWidget {
  const _SessionStatusChip({required this.status});

  final SessionStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (label, icon, color) = switch (status) {
      SessionStatus.scheduled => (
        'Scheduled',
        Icons.schedule_rounded,
        theme.colorScheme.tertiary,
      ),
      SessionStatus.live => (
        'Live',
        Icons.play_circle_fill_rounded,
        theme.colorScheme.primary,
      ),
      SessionStatus.completed => (
        'Completed',
        Icons.check_circle_outline_rounded,
        theme.colorScheme.secondary,
      ),
      SessionStatus.draft => (
        'Draft',
        Icons.edit_rounded,
        theme.colorScheme.onSurfaceVariant,
      ),
      SessionStatus.canceled => (
        'Canceled',
        Icons.cancel_rounded,
        theme.colorScheme.error,
      ),
    };

    return Chip(
      label: Text(label),
      avatar: Icon(icon, size: 18, color: color),
    );
  }
}

String _statusLabel(SessionStatus status) {
  return switch (status) {
    SessionStatus.scheduled => 'Scheduled',
    SessionStatus.live => 'Live',
    SessionStatus.completed => 'Completed',
    SessionStatus.draft => 'Draft',
    SessionStatus.canceled => 'Canceled',
  };
}

String _friendlyErrorMessage(String message) {
  if (message.contains('room already has a live session')) {
    return 'Could not set this session to Live. Another session is already '
        'live in this room. End that session first and try again.';
  }

  return message;
}

String _formatRange(String startTime, String endTime) {
  final base = DateTime(2024);
  final formatter = DateFormat.jm();
  final start = _parseHHmm(startTime);
  final end = _parseHHmm(endTime);

  final startDate = DateTime(
    base.year,
    base.month,
    base.day,
    start.hour,
    start.minute,
  );
  final endDate = DateTime(
    base.year,
    base.month,
    base.day,
    end.hour,
    end.minute,
  );

  return '${formatter.format(startDate)} - ${formatter.format(endDate)}';
}

({int hour, int minute}) _parseHHmm(String value) {
  final parts = value.split(':');
  if (parts.length != 2) return (hour: 0, minute: 0);

  final hour = int.tryParse(parts[0]) ?? 0;
  final minute = int.tryParse(parts[1]) ?? 0;
  return (hour: hour, minute: minute);
}
