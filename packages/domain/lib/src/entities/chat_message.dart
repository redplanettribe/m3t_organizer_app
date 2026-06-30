import 'package:domain/src/entities/chat_reaction.dart';
import 'package:domain/src/entities/chat_reply_to.dart';
import 'package:domain/src/enums/chat_channel_type.dart';
import 'package:equatable/equatable.dart';

/// Domain chat message (general, DM, or organizers backstage).
final class ChatMessage extends Equatable {
  const ChatMessage({
    required this.messageId,
    required this.eventId,
    required this.channelType,
    required this.senderUserId,
    required this.body,
    required this.createdAt,
    this.conversationId,
    this.senderName,
    this.senderLastName,
    this.senderProfilePictureUrl,
    this.recipientUserId,
    this.replyTo,
    this.reactions,
  });

  final String messageId;
  final String eventId;
  final ChatChannelType channelType;
  final String? conversationId;
  final String senderUserId;
  final String? senderName;
  final String? senderLastName;
  final String? senderProfilePictureUrl;
  final String? recipientUserId;
  final String body;
  final ChatReplyTo? replyTo;
  final List<ChatReaction>? reactions;
  final DateTime createdAt;

  @override
  List<Object?> get props => [
    messageId,
    eventId,
    channelType,
    conversationId,
    senderUserId,
    senderName,
    senderLastName,
    senderProfilePictureUrl,
    recipientUserId,
    body,
    replyTo,
    reactions,
    createdAt,
  ];
}
