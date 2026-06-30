// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_ban.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatBan _$ChatBanFromJson(Map<String, dynamic> json) => ChatBan(
  userId: json['user_id'] as String,
  userName: json['user_name'] as String?,
  userLastName: json['user_last_name'] as String?,
  bannedByUserId: json['banned_by_user_id'] as String?,
  bannedByName: json['banned_by_name'] as String?,
  bannedByLastName: json['banned_by_last_name'] as String?,
  bannedAt: json['banned_at'] as String?,
);

Map<String, dynamic> _$ChatBanToJson(ChatBan instance) => <String, dynamic>{
  'user_id': instance.userId,
  'user_name': instance.userName,
  'user_last_name': instance.userLastName,
  'banned_by_user_id': instance.bannedByUserId,
  'banned_by_name': instance.bannedByName,
  'banned_by_last_name': instance.bannedByLastName,
  'banned_at': instance.bannedAt,
};
