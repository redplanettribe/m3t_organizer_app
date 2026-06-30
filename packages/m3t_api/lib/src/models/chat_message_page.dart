import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:m3t_api/src/models/chat_message.dart';

part 'chat_message_page.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
final class ChatMessagePage extends Equatable {
  const ChatMessagePage({
    required this.items,
    this.nextCursor,
  });

  factory ChatMessagePage.fromJson(Map<String, dynamic> json) =>
      _$ChatMessagePageFromJson(json);

  final List<ChatMessage> items;
  final String? nextCursor;

  ChatMessagePage copyWith({
    List<ChatMessage>? items,
    Object? nextCursor = _sentinel,
  }) {
    return ChatMessagePage(
      items: items ?? this.items,
      nextCursor: nextCursor == _sentinel
          ? this.nextCursor
          : nextCursor as String?,
    );
  }

  Map<String, dynamic> toJson() => _$ChatMessagePageToJson(this);

  static const _sentinel = Object();

  @override
  List<Object?> get props => [items, nextCursor];
}
