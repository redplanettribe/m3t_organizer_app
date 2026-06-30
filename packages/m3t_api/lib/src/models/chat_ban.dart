import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'chat_ban.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
final class ChatBan extends Equatable {
  const ChatBan({
    required this.userId,
    this.userName,
    this.userLastName,
    this.bannedByUserId,
    this.bannedByName,
    this.bannedByLastName,
    this.bannedAt,
  });

  factory ChatBan.fromJson(Map<String, dynamic> json) =>
      _$ChatBanFromJson(json);

  final String userId;
  final String? userName;
  final String? userLastName;
  final String? bannedByUserId;
  final String? bannedByName;
  final String? bannedByLastName;
  final String? bannedAt;

  ChatBan copyWith({
    String? userId,
    Object? userName = _sentinel,
    Object? userLastName = _sentinel,
    Object? bannedByUserId = _sentinel,
    Object? bannedByName = _sentinel,
    Object? bannedByLastName = _sentinel,
    Object? bannedAt = _sentinel,
  }) {
    return ChatBan(
      userId: userId ?? this.userId,
      userName: userName == _sentinel ? this.userName : userName as String?,
      userLastName: userLastName == _sentinel
          ? this.userLastName
          : userLastName as String?,
      bannedByUserId: bannedByUserId == _sentinel
          ? this.bannedByUserId
          : bannedByUserId as String?,
      bannedByName: bannedByName == _sentinel
          ? this.bannedByName
          : bannedByName as String?,
      bannedByLastName: bannedByLastName == _sentinel
          ? this.bannedByLastName
          : bannedByLastName as String?,
      bannedAt: bannedAt == _sentinel ? this.bannedAt : bannedAt as String?,
    );
  }

  Map<String, dynamic> toJson() => _$ChatBanToJson(this);

  static const _sentinel = Object();

  @override
  List<Object?> get props => [
    userId,
    userName,
    userLastName,
    bannedByUserId,
    bannedByName,
    bannedByLastName,
    bannedAt,
  ];
}
