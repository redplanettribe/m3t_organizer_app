import 'package:equatable/equatable.dart';

/// Aggregated emoji reaction row on a chat message.
final class ChatReaction extends Equatable {
  const ChatReaction({
    required this.emoji,
    required this.count,
    this.reactedByMe = false,
  });

  final String emoji;
  final int count;
  final bool reactedByMe;

  @override
  List<Object?> get props => [emoji, count, reactedByMe];
}
