// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_reply_to.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatReplyTo _$ChatReplyToFromJson(Map<String, dynamic> json) => ChatReplyTo(
  messageId: json['message_id'] as String,
  senderUserId: json['sender_user_id'] as String,
  senderName: json['sender_name'] as String?,
  senderLastName: json['sender_last_name'] as String?,
  body: json['body'] as String?,
  deleted: json['deleted'] as bool? ?? false,
);

Map<String, dynamic> _$ChatReplyToToJson(ChatReplyTo instance) =>
    <String, dynamic>{
      'message_id': instance.messageId,
      'sender_user_id': instance.senderUserId,
      'sender_name': instance.senderName,
      'sender_last_name': instance.senderLastName,
      'body': instance.body,
      'deleted': instance.deleted,
    };
