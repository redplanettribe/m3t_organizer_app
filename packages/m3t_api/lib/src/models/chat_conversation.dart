import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:m3t_api/src/models/chat_message.dart';

part 'chat_conversation.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
final class ChatConversation extends Equatable {
  const ChatConversation({
    required this.conversationId,
    required this.otherUserId,
    this.lastMessage,
  });

  factory ChatConversation.fromJson(Map<String, dynamic> json) =>
      _$ChatConversationFromJson(json);

  final String conversationId;
  final String otherUserId;
  final ChatMessage? lastMessage;

  ChatConversation copyWith({
    String? conversationId,
    String? otherUserId,
    Object? lastMessage = _sentinel,
  }) {
    return ChatConversation(
      conversationId: conversationId ?? this.conversationId,
      otherUserId: otherUserId ?? this.otherUserId,
      lastMessage: lastMessage == _sentinel
          ? this.lastMessage
          : lastMessage as ChatMessage?,
    );
  }

  Map<String, dynamic> toJson() => _$ChatConversationToJson(this);

  static const _sentinel = Object();

  @override
  List<Object?> get props => [conversationId, otherUserId, lastMessage];
}
