import 'package:domain/src/entities/chat_message.dart';
import 'package:domain/src/entities/chat_reaction.dart';
import 'package:domain/src/enums/chat_channel_type.dart';
import 'package:equatable/equatable.dart';

/// Multiplexed chat WebSocket push events.
sealed class ChatRealtimeEvent extends Equatable {
  const ChatRealtimeEvent();
}

final class ChatMessageReceived extends ChatRealtimeEvent {
  const ChatMessageReceived({required this.message});

  final ChatMessage message;

  @override
  List<Object?> get props => [message];
}

final class ChatMessageDeleted extends ChatRealtimeEvent {
  const ChatMessageDeleted({
    required this.messageId,
    required this.eventId,
    required this.channelType,
    this.conversationId,
    this.deletedAt,
  });

  final String messageId;
  final String eventId;
  final ChatChannelType channelType;
  final String? conversationId;
  final DateTime? deletedAt;

  @override
  List<Object?> get props => [
    messageId,
    eventId,
    channelType,
    conversationId,
    deletedAt,
  ];
}

final class ChatReactionAdded extends ChatRealtimeEvent {
  const ChatReactionAdded({
    required this.messageId,
    required this.reactions,
  });

  final String messageId;
  final List<ChatReaction> reactions;

  @override
  List<Object?> get props => [messageId, reactions];
}

final class ChatReactionRemoved extends ChatRealtimeEvent {
  const ChatReactionRemoved({
    required this.messageId,
    required this.reactions,
  });

  final String messageId;
  final List<ChatReaction> reactions;

  @override
  List<Object?> get props => [messageId, reactions];
}
