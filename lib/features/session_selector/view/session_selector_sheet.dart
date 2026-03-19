import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:m3t_organizer/features/session_selector/view/room_grouped_sessions_list.dart';

final class SessionSelectorSheet extends StatelessWidget {
  const SessionSelectorSheet({
    required this.rooms,
    required this.selectedSessionID,
    required this.selectedSession,
    required this.isCollapsed,
    required this.onSelectSession,
    required this.scrollController,
    super.key,
  });

  final List<RoomWithSessions> rooms;
  final String selectedSessionID;
  final Session? selectedSession;
  final bool isCollapsed;
  final ValueChanged<Session> onSelectSession;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      child: ListView(
        controller: scrollController,
        padding: EdgeInsets.zero,
        children: [
          const SizedBox(height: 8),
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _SheetHeader(
              theme: theme,
              selectedSession: selectedSession,
              isCollapsed: isCollapsed,
            ),
          ),
          if (!isCollapsed)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              child: RoomGroupedSessionsList(
                rooms: rooms,
                selectedSessionID: selectedSessionID,
                onSelectSession: onSelectSession,
              ),
            ),
        ],
      ),
    );
  }
}

final class _SheetHeader extends StatelessWidget {
  const _SheetHeader({
    required this.theme,
    required this.selectedSession,
    required this.isCollapsed,
  });

  final ThemeData theme;
  final Session? selectedSession;
  final bool isCollapsed;

  @override
  Widget build(BuildContext context) {
    if (isCollapsed && selectedSession != null) {
      return Row(
        children: [
          Icon(
            Icons.event_available_rounded,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  selectedSession!.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Day ${selectedSession!.eventDay}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        Icon(
          Icons.view_stream_rounded,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 8),
        Text('Select a session', style: theme.textTheme.titleMedium),
      ],
    );
  }
}
