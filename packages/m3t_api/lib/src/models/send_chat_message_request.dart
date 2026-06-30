import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'send_chat_message_request.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
final class SendChatMessageRequest extends Equatable {
  const SendChatMessageRequest({
    required this.body,
    this.clientMsgId,
    this.replyToMessageId,
  });

  factory SendChatMessageRequest.fromJson(Map<String, dynamic> json) =>
      _$SendChatMessageRequestFromJson(json);

  final String body;
  final String? clientMsgId;
  final String? replyToMessageId;

  SendChatMessageRequest copyWith({
    String? body,
    Object? clientMsgId = _sentinel,
    Object? replyToMessageId = _sentinel,
  }) {
    return SendChatMessageRequest(
      body: body ?? this.body,
      clientMsgId: clientMsgId == _sentinel
          ? this.clientMsgId
          : clientMsgId as String?,
      replyToMessageId: replyToMessageId == _sentinel
          ? this.replyToMessageId
          : replyToMessageId as String?,
    );
  }

  Map<String, dynamic> toJson() => _$SendChatMessageRequestToJson(this);

  static const _sentinel = Object();

  @override
  List<Object?> get props => [body, clientMsgId, replyToMessageId];
}
