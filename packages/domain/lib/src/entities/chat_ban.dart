import 'package:equatable/equatable.dart';

/// A user banned from sending event chat messages.
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

  final String userId;
  final String? userName;
  final String? userLastName;
  final String? bannedByUserId;
  final String? bannedByName;
  final String? bannedByLastName;
  final DateTime? bannedAt;

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
