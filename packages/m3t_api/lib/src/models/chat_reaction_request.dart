import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'chat_reaction_request.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
final class ChatReactionRequest extends Equatable {
  const ChatReactionRequest({required this.emoji});

  factory ChatReactionRequest.fromJson(Map<String, dynamic> json) =>
      _$ChatReactionRequestFromJson(json);

  final String emoji;

  ChatReactionRequest copyWith({String? emoji}) {
    return ChatReactionRequest(emoji: emoji ?? this.emoji);
  }

  Map<String, dynamic> toJson() => _$ChatReactionRequestToJson(this);

  @override
  List<Object?> get props => [emoji];
}
