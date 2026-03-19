import 'package:flutter/material.dart';
import 'package:m3t_organizer/features/organizer_event/view/selected_session_check_in_panel.dart';
import 'package:m3t_organizer/features/organizer_event/view/session_demo_models.dart';
import 'package:m3t_organizer/features/organizer_event/view/session_selector_sheet.dart';

final class SessionsTab extends StatefulWidget {
  const SessionsTab({super.key});

  @override
  State<SessionsTab> createState() => _SessionsTabState();
}

final class _SessionsTabState extends State<SessionsTab> {
  late final List<SessionRoomDemo> _rooms;
  late SessionDemo _selectedSession;
  late String _selectedRoomName;

  @override
  void initState() {
    super.initState();
    _rooms = buildSessionDemoData();
    _selectedSession = _rooms.first.sessions.first;
    _selectedRoomName = _rooms.first.name;
  }

  void _selectSession(SessionDemo session) {
    for (final room in _rooms) {
      final hasSession = room.sessions.any((item) => item.id == session.id);
      if (hasSession) {
        setState(() {
          _selectedSession = session;
          _selectedRoomName = room.name;
        });
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SelectedSessionCheckInPanel(
          roomName: _selectedRoomName,
          session: _selectedSession,
        ),
        DraggableScrollableSheet(
          initialChildSize: 0.34,
          maxChildSize: 0.76,
          builder: (context, scrollController) {
            return SessionSelectorSheet(
              rooms: _rooms,
              selectedSessionID: _selectedSession.id,
              onSelectSession: _selectSession,
              scrollController: scrollController,
            );
          },
        ),
      ],
    );
  }
}
