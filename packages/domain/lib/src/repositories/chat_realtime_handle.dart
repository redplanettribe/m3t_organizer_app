/// Long-lived chat WebSocket subscription; call [cancel] when done.
// ignore: one_member_abstracts
abstract interface class ChatRealtimeHandle {
  void cancel();
}
