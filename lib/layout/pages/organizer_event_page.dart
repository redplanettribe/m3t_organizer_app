import 'package:flutter/material.dart';
import 'package:m3t_organizer/layout/pages/event_workspace_scaffold.dart';

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

    return EventWorkspaceScaffold(
      eventID: eventID,
      appBar: AppBar(
        titleSpacing: 0,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
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
      ),
    );
  }
}
