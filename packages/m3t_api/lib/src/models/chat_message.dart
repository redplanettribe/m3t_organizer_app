import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:m3t_api/src/models/chat_reaction.dart';
import 'package:m3t_api/src/models/chat_reply_to.dart';

part 'chat_message.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
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

  factory ChatMessage.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageFromJson(json);

  final String messageId;
  final String eventId;
  final String channelType;
  final String? conversationId;
  final String senderUserId;
  final String? senderName;
  final String? senderLastName;
  final String? senderProfilePictureUrl;
  final String? recipientUserId;
  final String body;
  final ChatReplyTo? replyTo;
  final List<ChatReaction>? reactions;
  final String createdAt;

  ChatMessage copyWith({
    String? messageId,
    String? eventId,
    String? channelType,
    Object? conversationId = _sentinel,
    String? senderUserId,
    Object? senderName = _sentinel,
    Object? senderLastName = _sentinel,
    Object? senderProfilePictureUrl = _sentinel,
    Object? recipientUserId = _sentinel,
    String? body,
    Object? replyTo = _sentinel,
    Object? reactions = _sentinel,
    String? createdAt,
  }) {
    return ChatMessage(
      messageId: messageId ?? this.messageId,
      eventId: eventId ?? this.eventId,
      channelType: channelType ?? this.channelType,
      conversationId: conversationId == _sentinel
          ? this.conversationId
          : conversationId as String?,
      senderUserId: senderUserId ?? this.senderUserId,
      senderName: senderName == _sentinel
          ? this.senderName
          : senderName as String?,
      senderLastName: senderLastName == _sentinel
          ? this.senderLastName
          : senderLastName as String?,
      senderProfilePictureUrl: senderProfilePictureUrl == _sentinel
          ? this.senderProfilePictureUrl
          : senderProfilePictureUrl as String?,
      recipientUserId: recipientUserId == _sentinel
          ? this.recipientUserId
          : recipientUserId as String?,
      body: body ?? this.body,
      replyTo: replyTo == _sentinel ? this.replyTo : replyTo as ChatReplyTo?,
      reactions: reactions == _sentinel
          ? this.reactions
          : reactions as List<ChatReaction>?,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => _$ChatMessageToJson(this);

  static const _sentinel = Object();

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
