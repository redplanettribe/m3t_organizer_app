// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'room_with_sessions.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RoomWithSessions _$RoomWithSessionsFromJson(Map<String, dynamic> json) =>
    RoomWithSessions(
      room: Room.fromJson(json['room'] as Map<String, dynamic>),
      sessions: (json['sessions'] as List<dynamic>)
          .map((e) => Session.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$RoomWithSessionsToJson(RoomWithSessions instance) =>
    <String, dynamic>{'room': instance.room, 'sessions': instance.sessions};
