// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_ban_page.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatBanPage _$ChatBanPageFromJson(Map<String, dynamic> json) => ChatBanPage(
  items: (json['items'] as List<dynamic>)
      .map((e) => ChatBan.fromJson(e as Map<String, dynamic>))
      .toList(),
  pagination: json['pagination'] == null
      ? null
      : PaginationMeta.fromJson(json['pagination'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ChatBanPageToJson(ChatBanPage instance) =>
    <String, dynamic>{
      'items': instance.items,
      'pagination': instance.pagination,
    };
