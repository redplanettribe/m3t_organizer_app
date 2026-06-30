import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:m3t_api/src/models/chat_conversation.dart';

part 'chat_conversation_page.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
final class ChatConversationPage extends Equatable {
  const ChatConversationPage({
    required this.items,
    this.nextCursor,
  });

  factory ChatConversationPage.fromJson(Map<String, dynamic> json) =>
      _$ChatConversationPageFromJson(json);

  final List<ChatConversation> items;
  final String? nextCursor;

  ChatConversationPage copyWith({
    List<ChatConversation>? items,
    Object? nextCursor = _sentinel,
  }) {
    return ChatConversationPage(
      items: items ?? this.items,
      nextCursor: nextCursor == _sentinel
          ? this.nextCursor
          : nextCursor as String?,
    );
  }

  Map<String, dynamic> toJson() => _$ChatConversationPageToJson(this);

  static const _sentinel = Object();

  @override
  List<Object?> get props => [items, nextCursor];
}
