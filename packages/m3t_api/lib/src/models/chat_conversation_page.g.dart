// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_conversation_page.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatConversationPage _$ChatConversationPageFromJson(
  Map<String, dynamic> json,
) => ChatConversationPage(
  items: (json['items'] as List<dynamic>)
      .map((e) => ChatConversation.fromJson(e as Map<String, dynamic>))
      .toList(),
  nextCursor: json['next_cursor'] as String?,
);

Map<String, dynamic> _$ChatConversationPageToJson(
  ChatConversationPage instance,
) => <String, dynamic>{
  'items': instance.items,
  'next_cursor': instance.nextCursor,
};
