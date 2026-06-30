// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatMessage _$ChatMessageFromJson(Map<String, dynamic> json) => ChatMessage(
  messageId: json['message_id'] as String,
  eventId: json['event_id'] as String,
  channelType: json['channel_type'] as String,
  senderUserId: json['sender_user_id'] as String,
  body: json['body'] as String,
  createdAt: json['created_at'] as String,
  conversationId: json['conversation_id'] as String?,
  senderName: json['sender_name'] as String?,
  senderLastName: json['sender_last_name'] as String?,
  senderProfilePictureUrl: json['sender_profile_picture_url'] as String?,
  recipientUserId: json['recipient_user_id'] as String?,
  replyTo: json['reply_to'] == null
      ? null
      : ChatReplyTo.fromJson(json['reply_to'] as Map<String, dynamic>),
  reactions: (json['reactions'] as List<dynamic>?)
      ?.map((e) => ChatReaction.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ChatMessageToJson(ChatMessage instance) =>
    <String, dynamic>{
      'message_id': instance.messageId,
      'event_id': instance.eventId,
      'channel_type': instance.channelType,
      'conversation_id': instance.conversationId,
      'sender_user_id': instance.senderUserId,
      'sender_name': instance.senderName,
      'sender_last_name': instance.senderLastName,
      'sender_profile_picture_url': instance.senderProfilePictureUrl,
      'recipient_user_id': instance.recipientUserId,
      'body': instance.body,
      'reply_to': instance.replyTo,
      'reactions': instance.reactions,
      'created_at': instance.createdAt,
    };
