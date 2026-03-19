import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:m3t_organizer/features/session_selector/view/qr_scanner_placeholder.dart';

final class SelectedSessionCheckInPanel extends StatelessWidget {
  const SelectedSessionCheckInPanel({
    required this.roomName,
    required this.session,
    super.key,
  });

  final String roomName;
  final Session session;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeLabel = _formatRange(session.startTime, session.endTime);
    final status = _statusForSession(session);

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
                              session.title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Day ${session.eventDay} • '
                              '$timeLabel • $roomName',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      _SessionStatusChip(status: status),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Session state',
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Use these controls to manage session flow. '
                    'This is view-only for now.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: null,
                          icon: const Icon(Icons.play_circle_fill_rounded),
                          label: const Text('Start now'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: null,
                          icon: const Icon(Icons.stop_circle_outlined),
                          label: const Text('End now'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: QrScannerPlaceholder(
                compact: true,
                title: 'Session check-in scanner',
                subtitle: 'Scan attendee QR to check in to selected session.',
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Latest session check-in',
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Attendee: user_2c1... • 11:16 AM',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Chip(
                    label: const Text('Checked in'),
                    avatar: Icon(
                      Icons.check_circle_outline_rounded,
                      size: 18,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum SessionStatusVisual { upcoming, ongoing, ended }

SessionStatusVisual _statusForSession(Session session) {
  final now = DateTime.now();
  final nowMinutes = (now.hour * 60) + now.minute;
  final start = _parseHHmm(session.startTime);
  final end = _parseHHmm(session.endTime);
  final startMinutes = (start.hour * 60) + start.minute;
  final endMinutes = (end.hour * 60) + end.minute;

  if (nowMinutes < startMinutes) return SessionStatusVisual.upcoming;
  if (nowMinutes > endMinutes) return SessionStatusVisual.ended;
  return SessionStatusVisual.ongoing;
}

final class _SessionStatusChip extends StatelessWidget {
  const _SessionStatusChip({required this.status});

  final SessionStatusVisual status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (label, icon, color) = switch (status) {
      SessionStatusVisual.upcoming => (
        'Upcoming',
        Icons.schedule_rounded,
        theme.colorScheme.tertiary,
      ),
      SessionStatusVisual.ongoing => (
        'On-going',
        Icons.play_circle_fill_rounded,
        theme.colorScheme.primary,
      ),
      SessionStatusVisual.ended => (
        'Ended',
        Icons.stop_circle_rounded,
        theme.colorScheme.error,
      ),
    };

    return Chip(
      label: Text(label),
      avatar: Icon(icon, size: 18, color: color),
    );
  }
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
