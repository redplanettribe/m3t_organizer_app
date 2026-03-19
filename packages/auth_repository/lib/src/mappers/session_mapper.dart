import 'package:auth_repository/src/mappers/speaker_mapper.dart';
import 'package:auth_repository/src/mappers/tag_mapper.dart';
import 'package:domain/domain.dart' as domain;
import 'package:m3t_api/m3t_api.dart' as api;

extension ApiSessionMapper on api.Session {
  domain.Session toDomain() => domain.Session(
    id: id,
    roomID: roomId,
    title: title,
    eventDay: eventDay,
    startTime: startTime,
    endTime: endTime,
    status:
        status != null ? domain.sessionStatusFromApiValue(status!) : null,
    description: description,
    source: source,
    sourceSessionId: sourceSessionId,
    speakers: (speakers ?? const <api.Speaker>[])
        .map((s) => s.toDomain())
        .toList(),
    tags: (tags ?? const <api.Tag>[]).map((t) => t.toDomain()).toList(),
  );
}
