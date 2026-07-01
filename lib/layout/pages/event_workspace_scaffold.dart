import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m3t_organizer/core/push/push_navigation_intent.dart';
import 'package:m3t_organizer/core/push/push_notification_cubit.dart';
import 'package:m3t_organizer/features/chat/chat.dart';
import 'package:m3t_organizer/features/session_selector/session_selector.dart';
import 'package:m3t_organizer/layout/sections/event_actions_section.dart';

/// Event workspace with bottom navigation: actions, sessions, chat.
final class EventWorkspaceScaffold extends StatefulWidget {
  const EventWorkspaceScaffold({
    required this.eventID,
    required this.appBar,
    this.pushIntent,
    super.key,
  });

  final String eventID;
  final PreferredSizeWidget appBar;
  final PushNavigationIntent? pushIntent;

  @override
  State<EventWorkspaceScaffold> createState() => _EventWorkspaceScaffoldState();
}

final class _EventWorkspaceScaffoldState extends State<EventWorkspaceScaffold>
    with AutomaticKeepAliveClientMixin {
  late int _selectedIndex;
  bool _isSessionSheetExpanded = false;
  PushNotificationCubit? _pushNotificationCubit;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _pushNotificationCubit = context.read<PushNotificationCubit>();
  }

  @override
  void initState() {
    super.initState();
    _selectedIndex = _initialTabIndex(widget.pushIntent);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _syncChatNavPresence();
    });
  }

  @override
  void dispose() {
    _pushNotificationCubit?.clearChatForegroundPresence();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant EventWorkspaceScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pushIntent != widget.pushIntent &&
        widget.pushIntent != null) {
      setState(() {
        _selectedIndex = _initialTabIndex(widget.pushIntent);
      });
      _syncChatNavPresence();
    }
  }

  int _initialTabIndex(PushNavigationIntent? intent) {
    return switch (intent) {
      OpenEventChatGeneralIntent() ||
      OpenEventDmIntent() ||
      OpenEventChatOrganizersIntent() => 2,
      OpenEventSessionsIntent() => 1,
      _ => 0,
    };
  }

  PushNavigationIntent? get _chatPushIntent {
    return switch (widget.pushIntent) {
      OpenEventChatGeneralIntent() ||
      OpenEventDmIntent() ||
      OpenEventChatOrganizersIntent() => widget.pushIntent,
      _ => null,
    };
  }

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
      _syncChatNavPresence();
    }
  }

  void _syncChatNavPresence() {
    _pushNotificationCubit?.setEventChatNavActive(
      eventId: widget.eventID,
      active: _selectedIndex == 2,
    );
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
          ChatHomePage(
            eventID: widget.eventID,
            pushIntent: _chatPushIntent,
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
