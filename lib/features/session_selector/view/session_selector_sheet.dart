import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:m3t_organizer/features/session_selector/view/room_grouped_sessions_list.dart';

final class SessionSelectorSheet extends StatelessWidget {
  const SessionSelectorSheet({
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
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: theme.colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(
                  Icons.view_stream_rounded,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text('Select a session', style: theme.textTheme.titleMedium),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: RoomGroupedSessionsList(
              rooms: rooms,
              selectedSessionID: selectedSessionID,
              onSelectSession: onSelectSession,
              scrollController: scrollController,
            ),
          ),
        ],
      ),
    );
  }
}
