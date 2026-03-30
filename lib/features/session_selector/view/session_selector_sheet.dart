import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:m3t_organizer/core/widgets/session_status_chip.dart';
import 'package:m3t_organizer/features/session_selector/view/room_grouped_sessions_list.dart';

final class SessionSelectorSheet extends StatelessWidget {
  const SessionSelectorSheet({
    required this.rooms,
    required this.selectedSessionID,
    required this.selectedSession,
    required this.isCollapsed,
    required this.onSelectSession,
    required this.scrollController,
    required this.onTapHeader,
    this.isExpanded = false,
    super.key,
  });

  final List<RoomWithSessions> rooms;
  final String selectedSessionID;
  final Session? selectedSession;
  final bool isCollapsed;
  final bool isExpanded;
  final ValueChanged<Session> onSelectSession;
  final ScrollController scrollController;
  final VoidCallback onTapHeader;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const sheetBorderRadius = BorderRadius.all(Radius.circular(24));

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: sheetBorderRadius,
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: onTapHeader,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
              child: _SheetHeader(
                theme: theme,
                selectedSession: selectedSession,
                isCollapsed: isCollapsed,
                isExpanded: isExpanded,
              ),
            ),
          ),
          if (!isCollapsed)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: RoomGroupedSessionsList(
                    rooms: rooms,
                    selectedSessionID: selectedSessionID,
                    onSelectSession: onSelectSession,
                  ),
                ),
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
    required this.isExpanded,
  });

  final ThemeData theme;
  final Session? selectedSession;
  final bool isCollapsed;
  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    if (isCollapsed && selectedSession != null) {
      final session = selectedSession!;
      return Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.event_available_rounded,
              color: theme.colorScheme.onPrimaryContainer,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
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
                SessionStatusChip(status: session.status, compact: true),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.keyboard_arrow_down_rounded,
            color: theme.colorScheme.primary,
          ),
        ],
      );
    }

    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.view_stream_rounded,
            color: theme.colorScheme.onSurfaceVariant,
            size: 20,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Select a session', style: theme.textTheme.titleMedium),
              if (isExpanded)
                Text(
                  'Tap to collapse',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                )
              else
                Text(
                  'Tap to expand',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Icon(
          isCollapsed
              ? Icons.keyboard_arrow_down_rounded
              : Icons.keyboard_arrow_up_rounded,
          color: theme.colorScheme.primary,
        ),
      ],
    );
  }
}
