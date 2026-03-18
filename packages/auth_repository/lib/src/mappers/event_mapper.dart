import 'package:domain/domain.dart' as domain;
import 'package:m3t_api/m3t_api.dart' as api;

extension ApiEventMapper on api.Event {
  domain.Event toDomain() => domain.Event(
    id: id,
    name: name,
    startDate: startDate != null ? DateTime.tryParse(startDate!) : null,
    durationDays: durationDays,
    description: description,
    eventCode: eventCode,
    locationLat: locationLat,
    locationLng: locationLng,
    ownerId: ownerId,
    thumbnailUrl: thumbnailUrl,
    createdAt: createdAt != null ? DateTime.tryParse(createdAt!) : null,
    updatedAt: updatedAt != null ? DateTime.tryParse(updatedAt!) : null,
  );
}

//
