import 'package:domain/src/entities/speaker.dart';
import 'package:domain/src/entities/tag.dart';
import 'package:domain/src/enums/session_status.dart';
import 'package:equatable/equatable.dart';

/// Domain representation of a session inside a room.
///
/// Note: API returns `start_time` / `end_time` as `HH:mm` strings.
/// We keep them as strings in domain (no Flutter dependency).
final class Session extends Equatable {
  const Session({
    required this.id,
    required this.roomID,
    required this.title,
    required this.eventDay,
    required this.startTime,
    required this.endTime,
    this.status,
    this.description,
    this.source,
    this.sourceSessionId,
    this.speakers = const <Speaker>[],
    this.tags = const <Tag>[],
  });

  final String id;
  final String roomID;
  final String title;
  final int eventDay;
  final String startTime;
  final String endTime;
  final SessionStatus? status;
  final String? description;
  final String? source;
  final String? sourceSessionId;
  final List<Speaker> speakers;
  final List<Tag> tags;

  @override
  List<Object?> get props => [
    id,
    roomID,
    title,
    eventDay,
    startTime,
    endTime,
    status,
    description,
    source,
    sourceSessionId,
    speakers,
    tags,
  ];
}
