import 'package:domain/src/entities/chat_conversation.dart';
import 'package:equatable/equatable.dart';

/// Cursor-paginated DM conversation list page.
final class ChatConversationPage extends Equatable {
  const ChatConversationPage({
    required this.items,
    this.nextCursor,
  });

  final List<ChatConversation> items;
  final String? nextCursor;

  @override
  List<Object?> get props => [items, nextCursor];
}
