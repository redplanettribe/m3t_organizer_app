// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_reaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatReaction _$ChatReactionFromJson(Map<String, dynamic> json) => ChatReaction(
  emoji: json['emoji'] as String,
  count: (json['count'] as num).toInt(),
  reactedByMe: json['reacted_by_me'] as bool? ?? false,
);

Map<String, dynamic> _$ChatReactionToJson(ChatReaction instance) =>
    <String, dynamic>{
      'emoji': instance.emoji,
      'count': instance.count,
      'reacted_by_me': instance.reactedByMe,
    };
