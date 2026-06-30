import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'chat_reaction.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
final class ChatReaction extends Equatable {
  const ChatReaction({
    required this.emoji,
    required this.count,
    this.reactedByMe = false,
  });

  factory ChatReaction.fromJson(Map<String, dynamic> json) =>
      _$ChatReactionFromJson(json);

  final String emoji;
  final int count;
  final bool reactedByMe;

  ChatReaction copyWith({
    String? emoji,
    int? count,
    bool? reactedByMe,
  }) {
    return ChatReaction(
      emoji: emoji ?? this.emoji,
      count: count ?? this.count,
      reactedByMe: reactedByMe ?? this.reactedByMe,
    );
  }

  Map<String, dynamic> toJson() => _$ChatReactionToJson(this);

  @override
  List<Object?> get props => [emoji, count, reactedByMe];
}
