// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'send_chat_message_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SendChatMessageRequest _$SendChatMessageRequestFromJson(
  Map<String, dynamic> json,
) => SendChatMessageRequest(
  body: json['body'] as String,
  clientMsgId: json['client_msg_id'] as String?,
  replyToMessageId: json['reply_to_message_id'] as String?,
);

Map<String, dynamic> _$SendChatMessageRequestToJson(
  SendChatMessageRequest instance,
) => <String, dynamic>{
  'body': instance.body,
  'client_msg_id': instance.clientMsgId,
  'reply_to_message_id': instance.replyToMessageId,
};
