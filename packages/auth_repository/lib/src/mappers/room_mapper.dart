import 'package:domain/domain.dart' as domain;
import 'package:m3t_api/m3t_api.dart' as api;

extension ApiRoomMapper on api.Room {
  domain.Room toDomain() => domain.Room(
    id: id,
    eventID: eventId,
    name: name,
    capacity: capacity,
    description: description,
    howToGetThere: howToGetThere,
    notBookable: notBookable,
    source: source,
    sourceSessionId: sourceSessionId,
    createdAt: createdAt != null ? DateTime.tryParse(createdAt!) : null,
    updatedAt: updatedAt != null ? DateTime.tryParse(updatedAt!) : null,
  );
}
