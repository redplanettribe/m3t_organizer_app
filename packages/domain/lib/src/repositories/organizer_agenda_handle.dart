/// Long-lived organizer agenda WebSocket subscription; call [cancel] when done.
// Single method is intentional — implementers live in the data package.
// ignore: one_member_abstracts
abstract interface class OrganizerAgendaHandle {
  void cancel();
}
