import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'chat_reply_to.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
final class ChatReplyTo extends Equatable {
  const ChatReplyTo({
    required this.messageId,
    required this.senderUserId,
    this.senderName,
    this.senderLastName,
    this.body,
    this.deleted = false,
  });

  factory ChatReplyTo.fromJson(Map<String, dynamic> json) =>
      _$ChatReplyToFromJson(json);

  final String messageId;
  final String senderUserId;
  final String? senderName;
  final String? senderLastName;
  final String? body;
  final bool deleted;

  ChatReplyTo copyWith({
    String? messageId,
    String? senderUserId,
    Object? senderName = _sentinel,
    Object? senderLastName = _sentinel,
    Object? body = _sentinel,
    bool? deleted,
  }) {
    return ChatReplyTo(
      messageId: messageId ?? this.messageId,
      senderUserId: senderUserId ?? this.senderUserId,
      senderName: senderName == _sentinel
          ? this.senderName
          : senderName as String?,
      senderLastName: senderLastName == _sentinel
          ? this.senderLastName
          : senderLastName as String?,
      body: body == _sentinel ? this.body : body as String?,
      deleted: deleted ?? this.deleted,
    );
  }

  Map<String, dynamic> toJson() => _$ChatReplyToToJson(this);

  static const _sentinel = Object();

  @override
  List<Object?> get props => [
    messageId,
    senderUserId,
    senderName,
    senderLastName,
    body,
    deleted,
  ];
}
