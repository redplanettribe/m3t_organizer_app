import 'package:equatable/equatable.dart';

/// Quoted parent message preview in a chat reply.
final class ChatReplyTo extends Equatable {
  const ChatReplyTo({
    required this.messageId,
    required this.senderUserId,
    this.senderName,
    this.senderLastName,
    this.body,
    this.deleted = false,
  });

  final String messageId;
  final String senderUserId;
  final String? senderName;
  final String? senderLastName;
  final String? body;
  final bool deleted;

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
