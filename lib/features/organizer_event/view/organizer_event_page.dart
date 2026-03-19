import 'package:flutter/material.dart';
import 'package:m3t_organizer/features/check_in_event/check_in_event.dart';
import 'package:m3t_organizer/features/session_selector/session_selector.dart';

final class OrganizerEventPage extends StatelessWidget {
  const OrganizerEventPage({
    required this.eventID,
    this.eventName,
    super.key,
  });

  final String eventID;
  final String? eventName;

  @override
  Widget build(BuildContext context) {
    final title = (eventName?.trim().isNotEmpty ?? false)
        ? eventName!
        : 'Event';
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: 0,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
              Text(
                'Organizer workspace',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          bottom: const TabBar(
            tabs: [
              Tab(
                text: 'Check-in',
                icon: Icon(Icons.qr_code_scanner_rounded),
              ),
              Tab(
                text: 'Sessions',
                icon: Icon(Icons.view_agenda_rounded),
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            _EventIdentityBanner(eventID: eventID),
            Expanded(
              child: TabBarView(
                children: [
                  CheckInEventTab(eventID: eventID),
                  SessionsTab(eventID: eventID),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final class _EventIdentityBanner extends StatelessWidget {
  const _EventIdentityBanner({required this.eventID});

  final String eventID;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(
            Icons.event_available_rounded,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Event ID: $eventID',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
