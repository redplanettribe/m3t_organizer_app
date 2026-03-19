import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:m3t_organizer/features/check_in_event/bloc/bloc.dart';
import 'package:m3t_organizer/features/check_in_event/view/event_qr_scanner.dart';

final class CheckInEventTab extends StatelessWidget {
  const CheckInEventTab({
    required this.eventID,
    super.key,
  });

  final String eventID;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CheckInEventCubit(
        eventID: eventID,
        eventsRepository: context.read<EventsRepository>(),
      ),
      child: const _CheckInEventTabView(),
    );
  }
}

final class _CheckInEventTabView extends StatelessWidget {
  const _CheckInEventTabView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<CheckInEventCubit, CheckInEventState>(
      builder: (context, state) {
        final latestCheckIn = state.latestCheckIn;

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: EventQrScanner(
                    enabled: !state.loading,
                    onUserIDDetected: context
                        .read<CheckInEventCubit>()
                        .onUserIDScanned,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (state.errorMessage != null) ...[
                Card(
                  color: theme.colorScheme.errorContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Text(
                      state.errorMessage!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Latest check-in',
                        style: theme.textTheme.titleSmall,
                      ),
                      const SizedBox(height: 12),
                      if (latestCheckIn == null) ...[
                        Text(
                          'No attendee checked in yet.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ] else ...[
                        _ResultRow(
                          label: 'Name',
                          value: _buildName(latestCheckIn),
                        ),
                        const SizedBox(height: 8),
                        _ResultRow(
                          label: 'Email',
                          value: latestCheckIn.email ?? '-',
                        ),
                        const SizedBox(height: 8),
                        _ResultRow(
                          label: 'User ID',
                          value: latestCheckIn.userID,
                        ),
                        const SizedBox(height: 8),
                        _ResultRow(
                          label: 'Time',
                          value: DateFormat(
                            'hh:mm a',
                          ).format(latestCheckIn.createdAt),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              'Status',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(width: 8),
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

  String _buildName(EventCheckIn checkIn) {
    final parts = <String>[];
    if (checkIn.name != null && checkIn.name!.trim().isNotEmpty) {
      parts.add(checkIn.name!.trim());
    }
    if (checkIn.lastName != null && checkIn.lastName!.trim().isNotEmpty) {
      parts.add(checkIn.lastName!.trim());
    }

    final fullName = parts.join(' ');

    if (fullName.isNotEmpty) {
      return fullName;
    }

    return '-';
  }
}

final class _ResultRow extends StatelessWidget {
  const _ResultRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Text(value, style: theme.textTheme.bodyMedium),
      ],
    );
  }
}
