// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_conversation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatConversation _$ChatConversationFromJson(Map<String, dynamic> json) =>
    ChatConversation(
      conversationId: json['conversation_id'] as String,
      otherUserId: json['other_user_id'] as String,
      lastMessage: json['last_message'] == null
          ? null
          : ChatMessage.fromJson(json['last_message'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ChatConversationToJson(ChatConversation instance) =>
    <String, dynamic>{
      'conversation_id': instance.conversationId,
      'other_user_id': instance.otherUserId,
      'last_message': instance.lastMessage,
    };
