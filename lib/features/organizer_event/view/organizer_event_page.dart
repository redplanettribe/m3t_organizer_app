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
