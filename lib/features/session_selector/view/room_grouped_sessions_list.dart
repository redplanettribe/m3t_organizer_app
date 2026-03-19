import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final class RoomGroupedSessionsList extends StatelessWidget {
  const RoomGroupedSessionsList({
    required this.rooms,
    required this.selectedSessionID,
    required this.onSelectSession,
    required this.scrollController,
    super.key,
  });

  final List<RoomWithSessions> rooms;
  final String selectedSessionID;
  final ValueChanged<Session> onSelectSession;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView.separated(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      itemCount: rooms.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, roomIndex) {
        final room = rooms[roomIndex];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        room.room.name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      '${room.room.capacity} seats',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                for (var index = 0; index < room.sessions.length; index++) ...[
                  _SessionTile(
                    session: room.sessions[index],
                    selected: room.sessions[index].id == selectedSessionID,
                    onTap: () => onSelectSession(room.sessions[index]),
                  ),
                  if (index != room.sessions.length - 1)
                    const SizedBox(height: 8),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

final class _SessionTile extends StatelessWidget {
  const _SessionTile({
    required this.session,
    required this.selected,
    required this.onTap,
  });

  final Session session;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeRange = _formatRange(session.startTime, session.endTime);
    final baseColor = selected
        ? theme.colorScheme.primaryContainer
        : theme.colorScheme.surfaceContainerHigh;

    return Material(
      color: baseColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Day ${session.eventDay} • $timeRange',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (selected)
                Icon(Icons.check_circle, color: theme.colorScheme.primary),
            ],
          ),
        ),
      ),
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
