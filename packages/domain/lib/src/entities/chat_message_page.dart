import 'package:domain/src/entities/chat_message.dart';
import 'package:equatable/equatable.dart';

/// Cursor-paginated chat message history page.
final class ChatMessagePage extends Equatable {
  const ChatMessagePage({
    required this.items,
    this.nextCursor,
  });

  final List<ChatMessage> items;
  final String? nextCursor;

  @override
  List<Object?> get props => [items, nextCursor];
}
