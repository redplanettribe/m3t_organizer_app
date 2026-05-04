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

  static const _sentinel = Object();

  Session copyWith({
    String? id,
    String? roomID,
    String? title,
    int? eventDay,
    String? startTime,
    String? endTime,
    Object? status = _sentinel,
    Object? description = _sentinel,
    Object? source = _sentinel,
    Object? sourceSessionId = _sentinel,
    List<Speaker>? speakers,
    List<Tag>? tags,
  }) {
    return Session(
      id: id ?? this.id,
      roomID: roomID ?? this.roomID,
      title: title ?? this.title,
      eventDay: eventDay ?? this.eventDay,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status == _sentinel ? this.status : status as SessionStatus?,
      description: description == _sentinel
          ? this.description
          : description as String?,
      source: source == _sentinel ? this.source : source as String?,
      sourceSessionId: sourceSessionId == _sentinel
          ? this.sourceSessionId
          : sourceSessionId as String?,
      speakers: speakers ?? this.speakers,
      tags: tags ?? this.tags,
    );
  }

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
