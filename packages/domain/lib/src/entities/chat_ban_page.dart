import 'package:domain/src/entities/chat_ban.dart';
import 'package:equatable/equatable.dart';

/// Page-based list of chat-banned attendees.
final class ChatBanPage extends Equatable {
  const ChatBanPage({
    required this.items,
    this.page,
    this.pageSize,
    this.total,
    this.totalPages,
  });

  final List<ChatBan> items;
  final int? page;
  final int? pageSize;
  final int? total;
  final int? totalPages;

  @override
  List<Object?> get props => [items, page, pageSize, total, totalPages];
}
