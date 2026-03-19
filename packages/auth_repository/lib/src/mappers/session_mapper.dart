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
    description: description,
    source: source,
    sourceSessionId: sourceSessionId,
  );
}
