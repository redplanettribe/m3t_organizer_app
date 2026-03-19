import 'package:flutter/material.dart';

final class SessionRoomDemo {
  const SessionRoomDemo({
    required this.id,
    required this.name,
    required this.capacity,
    required this.sessions,
  });

  final String id;
  final String name;
  final int capacity;
  final List<SessionDemo> sessions;
}

final class SessionDemo {
  const SessionDemo({
    required this.id,
    required this.title,
    required this.eventDay,
    required this.startTime,
    required this.endTime,
  });

  final String id;
  final String title;
  final int eventDay;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
}

List<SessionRoomDemo> buildSessionDemoData() {
  return const [
    SessionRoomDemo(
      id: 'room-main',
      name: 'Main Auditorium',
      capacity: 280,
      sessions: [
        SessionDemo(
          id: 'session-keynote',
          title: 'Opening Keynote',
          eventDay: 1,
          startTime: TimeOfDay(hour: 9, minute: 0),
          endTime: TimeOfDay(hour: 10, minute: 0),
        ),
        SessionDemo(
          id: 'session-product',
          title: 'Product Roadmap',
          eventDay: 1,
          startTime: TimeOfDay(hour: 10, minute: 30),
          endTime: TimeOfDay(hour: 11, minute: 30),
        ),
      ],
    ),
    SessionRoomDemo(
      id: 'room-labs',
      name: 'Labs Room',
      capacity: 90,
      sessions: [
        SessionDemo(
          id: 'session-workshop',
          title: 'Hands-on Workshop',
          eventDay: 1,
          startTime: TimeOfDay(hour: 11, minute: 45),
          endTime: TimeOfDay(hour: 12, minute: 30),
        ),
      ],
    ),
  ];
}
