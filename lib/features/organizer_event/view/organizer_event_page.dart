import 'package:flutter/material.dart';
import 'package:m3t_organizer/features/check_in_event/check_in_event.dart';
import 'package:m3t_organizer/features/session_selector/session_selector.dart';

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
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  bool _isSessionSheetExpanded = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this)
      ..addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController
      ..removeListener(_onTabChanged)
      ..dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.index != 1 && _isSessionSheetExpanded) {
      setState(() {
        _isSessionSheetExpanded = false;
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
    final title = (widget.eventName?.trim().isNotEmpty ?? false)
        ? widget.eventName!
        : 'Event';
    final theme = Theme.of(context);

    final hideDivider =
        _tabController.index == 1 && _isSessionSheetExpanded;

    return Scaffold(
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
        bottom: TabBar(
          controller: _tabController,
          dividerHeight: hideDivider ? 0 : null,
          tabs: const [
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
              controller: _tabController,
              children: [
                CheckInEventTab(eventID: widget.eventID),
                SessionsTab(
                  eventID: widget.eventID,
                  onSheetExpanded: _onSessionSheetExpansionChanged,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
