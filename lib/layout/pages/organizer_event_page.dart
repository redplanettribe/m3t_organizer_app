import 'package:flutter/material.dart';
import 'package:m3t_organizer/features/session_selector/session_selector.dart';
import 'package:m3t_organizer/layout/sections/event_actions_section.dart';

final class OrganizerEventPage extends StatefulWidget {
  const OrganizerEventPage({
    required this.eventID,
    this.eventName,
    super.key,
  });

  final String eventID;
  final String? eventName;

  @override
  State<OrganizerEventPage> createState() => _OrganizerEventPageState();
}

final class _OrganizerEventPageState extends State<OrganizerEventPage>
    with AutomaticKeepAliveClientMixin {
  int _selectedIndex = 0;
  bool _isSessionSheetExpanded = false;

  @override
  bool get wantKeepAlive => true;

  void _onDestinationSelected(int index) {
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
        if (_selectedIndex != 1 && _isSessionSheetExpanded) {
          _isSessionSheetExpanded = false;
        }
      });
    }
  }

  void _onSessionSheetExpansionChanged(bool expanded) {
    if (expanded != _isSessionSheetExpanded) {
      setState(() {
        _isSessionSheetExpanded = expanded;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final title = (widget.eventName?.trim().isNotEmpty ?? false)
        ? widget.eventName!
        : 'Event';
    final theme = Theme.of(context);

    final hideBottomDivider = _selectedIndex == 1 && _isSessionSheetExpanded;

    return Scaffold(
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
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          EventActionsSection(eventID: widget.eventID),
          SessionsView(
            eventID: widget.eventID,
            onSheetExpanded: _onSessionSheetExpansionChanged,
          ),
        ],
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          border: hideBottomDivider
              ? null
              : Border(
                  top: BorderSide(color: theme.colorScheme.outlineVariant),
                ),
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: _onDestinationSelected,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.qr_code_scanner_rounded),
              label: 'Event actions',
            ),
            NavigationDestination(
              icon: Icon(Icons.view_agenda_rounded),
              label: 'Sessions',
            ),
          ],
        ),
      ),
    );
  }
}
