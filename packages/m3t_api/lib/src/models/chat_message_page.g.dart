// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_message_page.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatMessagePage _$ChatMessagePageFromJson(Map<String, dynamic> json) =>
    ChatMessagePage(
      items: (json['items'] as List<dynamic>)
          .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
          .toList(),
      nextCursor: json['next_cursor'] as String?,
    );

Map<String, dynamic> _$ChatMessagePageToJson(ChatMessagePage instance) =>
    <String, dynamic>{
      'items': instance.items,
      'next_cursor': instance.nextCursor,
    };
