import 'package:flutter/material.dart';
import 'package:m3t_organizer/features/chat/chat.dart';
import 'package:m3t_organizer/features/session_selector/session_selector.dart';
import 'package:m3t_organizer/layout/sections/event_actions_section.dart';

/// Event workspace with bottom navigation: actions, sessions, chat.
final class EventWorkspaceScaffold extends StatefulWidget {
  const EventWorkspaceScaffold({
    required this.eventID,
    required this.appBar,
    super.key,
  });

  final String eventID;
  final PreferredSizeWidget appBar;

  @override
  State<EventWorkspaceScaffold> createState() => _EventWorkspaceScaffoldState();
}

final class _EventWorkspaceScaffoldState extends State<EventWorkspaceScaffold>
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
    final theme = Theme.of(context);
    final hideBottomDivider = _selectedIndex == 1 && _isSessionSheetExpanded;

    return Scaffold(
      key: ValueKey(widget.eventID),
      appBar: widget.appBar,
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          EventActionsSection(eventID: widget.eventID),
          SessionsView(
            eventID: widget.eventID,
            onSheetExpanded: _onSessionSheetExpansionChanged,
          ),
          ChatHomePage(eventID: widget.eventID),
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
            NavigationDestination(
              icon: Icon(Icons.chat_bubble_outline),
              label: 'Chat',
            ),
          ],
        ),
      ),
    );
  }
}
