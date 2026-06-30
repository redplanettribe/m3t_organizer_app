import 'package:domain/src/entities/chat_message.dart';
import 'package:equatable/equatable.dart';

/// DM inbox conversation preview.
final class ChatConversation extends Equatable {
  const ChatConversation({
    required this.conversationId,
    required this.otherUserId,
    this.lastMessage,
    this.otherParticipantDisplayName,
  });

  final String conversationId;
  final String otherUserId;
  final ChatMessage? lastMessage;
  final String? otherParticipantDisplayName;

  String get displayTitle =>
      otherParticipantDisplayName?.trim().isNotEmpty == true
      ? otherParticipantDisplayName!
      : otherUserId;

  @override
  List<Object?> get props => [
    conversationId,
    otherUserId,
    lastMessage,
    otherParticipantDisplayName,
  ];
}
