// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_message_reactions.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatMessageReactions _$ChatMessageReactionsFromJson(
  Map<String, dynamic> json,
) => ChatMessageReactions(
  messageId: json['message_id'] as String,
  reactions: (json['reactions'] as List<dynamic>)
      .map((e) => ChatReaction.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ChatMessageReactionsToJson(
  ChatMessageReactions instance,
) => <String, dynamic>{
  'message_id': instance.messageId,
  'reactions': instance.reactions,
};
