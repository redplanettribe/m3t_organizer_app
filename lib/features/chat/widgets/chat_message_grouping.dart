import 'package:domain/domain.dart';

/// Whether to show avatar + sender name for [message] in a message list.
///
/// Returns true when [message] is the first in a consecutive run from the same
/// sender (chronologically).
bool showSenderHeaderForMessage({
  required ChatMessage message,
  required ChatMessage? chronologicallyPreviousMessage,
}) {
  final previous = chronologicallyPreviousMessage;
  if (previous == null) return true;
  return previous.senderUserId != message.senderUserId;
}
