import 'package:flutter/material.dart';
import 'package:m3t_organizer/features/check_in_event/check_in_event.dart';
import 'package:m3t_organizer/features/deliverable_giveaway/deliverable_giveaway.dart';

/// Event actions tab: scrollable layout for check-in and deliverable giveaway.
final class EventActionsSection extends StatelessWidget {
  const EventActionsSection({
    required this.eventID,
    super.key,
  });

  final String eventID;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          EventCheckInView(eventID: eventID),
          const SizedBox(height: 28),
          DeliverableGiveawayView(eventID: eventID),
        ],
      ),
    );
  }
}
