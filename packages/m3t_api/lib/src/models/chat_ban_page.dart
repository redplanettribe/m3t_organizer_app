import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:m3t_api/src/models/chat_ban.dart';
import 'package:m3t_api/src/models/pagination_meta.dart';

part 'chat_ban_page.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
final class ChatBanPage extends Equatable {
  const ChatBanPage({
    required this.items,
    this.pagination,
  });

  factory ChatBanPage.fromJson(Map<String, dynamic> json) =>
      _$ChatBanPageFromJson(json);

  final List<ChatBan> items;
  final PaginationMeta? pagination;

  ChatBanPage copyWith({
    List<ChatBan>? items,
    Object? pagination = _sentinel,
  }) {
    return ChatBanPage(
      items: items ?? this.items,
      pagination: pagination == _sentinel
          ? this.pagination
          : pagination as PaginationMeta?,
    );
  }

  Map<String, dynamic> toJson() => _$ChatBanPageToJson(this);

  static const _sentinel = Object();

  @override
  List<Object?> get props => [items, pagination];
}
