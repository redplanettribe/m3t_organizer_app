import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:m3t_organizer/core/widgets/session_status_chip.dart';

final class RoomGroupedSessionsList extends StatelessWidget {
  const RoomGroupedSessionsList({
    required this.rooms,
    required this.selectedSessionID,
    required this.onSelectSession,
    super.key,
  });

  final List<RoomWithSessions> rooms;
  final String selectedSessionID;
  final ValueChanged<Session> onSelectSession;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        for (var roomIndex = 0; roomIndex < rooms.length; roomIndex++) ...[
          _RoomCard(
            theme: theme,
            room: rooms[roomIndex],
            selectedSessionID: selectedSessionID,
            onSelectSession: onSelectSession,
          ),
          if (roomIndex != rooms.length - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }
}

final class _RoomCard extends StatelessWidget {
  const _RoomCard({
    required this.theme,
    required this.room,
    required this.selectedSessionID,
    required this.onSelectSession,
  });

  final ThemeData theme;
  final RoomWithSessions room;
  final String selectedSessionID;
  final ValueChanged<Session> onSelectSession;

  @override
  Widget build(BuildContext context) {
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
    final scheme = theme.colorScheme;
    final timeRange = _formatRange(session.startTime, session.endTime);
    final isLive = session.status == SessionStatus.live;

    final Color fill;
    if (selected) {
      fill = scheme.primaryContainer;
    } else if (isLive) {
      fill = Color.alphaBlend(
        scheme.primary.withValues(alpha: 0.14),
        scheme.surfaceContainerHigh,
      );
    } else {
      fill = scheme.surfaceContainerHigh;
    }

    final BoxBorder? liveBorder = !selected && isLive
        ? Border.all(color: scheme.primary.withValues(alpha: 0.22))
        : null;

    const radius = 14.0;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(radius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: BorderRadius.circular(radius),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(radius),
            border: liveBorder,
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Day ${session.eventDay} • $timeRange',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SessionStatusChip(
                      status: session.status,
                      compact: true,
                    ),
                  ],
                ),
              ],
            ),
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
