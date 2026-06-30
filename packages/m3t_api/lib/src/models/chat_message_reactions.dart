import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:m3t_api/src/models/chat_reaction.dart';

part 'chat_message_reactions.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
final class ChatMessageReactions extends Equatable {
  const ChatMessageReactions({
    required this.messageId,
    required this.reactions,
  });

  factory ChatMessageReactions.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageReactionsFromJson(json);

  final String messageId;
  final List<ChatReaction> reactions;

  ChatMessageReactions copyWith({
    String? messageId,
    List<ChatReaction>? reactions,
  }) {
    return ChatMessageReactions(
      messageId: messageId ?? this.messageId,
      reactions: reactions ?? this.reactions,
    );
  }

  Map<String, dynamic> toJson() => _$ChatMessageReactionsToJson(this);

  @override
  List<Object?> get props => [messageId, reactions];
}
