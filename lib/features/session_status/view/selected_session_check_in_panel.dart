import 'dart:async' show unawaited;

import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:m3t_organizer/features/session_status/bloc/session_status_cubit.dart';

final class SelectedSessionCheckInPanel extends StatelessWidget {
  const SelectedSessionCheckInPanel({
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
    return BlocProvider(
      create: (context) {
        final cubit = SessionStatusCubit(
          eventID: eventID,
          sessionID: session.id,
          eventsRepository: context.read<EventsRepository>(),
        );
        return cubit..loadUnawaited();
      },
      child: BlocBuilder<SessionStatusCubit, SessionStatusState>(
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

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 280),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
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
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    activeSession.title,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    subtitle,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant,
                                        ),
                                  ),
                                ],
                              ),
                            ),
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

                        if (state.errorMessage != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            state.errorMessage!,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                          ),
                          const SizedBox(height: 8),
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

                const SizedBox(height: 12),

                _SpeakersCard(speakers: activeSession.speakers),

                const SizedBox(height: 12),

                _TagsCard(tags: activeSession.tags),
              ],
            ),
          );
        },
      ),
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

final class _SpeakersCard extends StatelessWidget {
  const _SpeakersCard({
    required this.speakers,
  });

  final List<Speaker> speakers;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Speakers',
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 10),
            if (speakers.isEmpty)
              Text(
                'No speakers.',
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
                    Chip(
                      label: Text(
                        '${speaker.firstName} ${speaker.lastName}',
                      ),
                      avatar: speaker.isTopSpeaker
                          ? const Icon(Icons.star_rounded, size: 18)
                          : null,
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

final class _TagsCard extends StatelessWidget {
  const _TagsCard({
    required this.tags,
  });

  final List<Tag> tags;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tags',
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 10),
            if (tags.isEmpty)
              Text(
                'No tags.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final tag in tags) Chip(label: Text(tag.name)),
                ],
              ),
          ],
        ),
      ),
    );
  }
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
