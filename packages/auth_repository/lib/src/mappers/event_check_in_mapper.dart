import 'package:domain/domain.dart' as domain;
import 'package:m3t_api/m3t_api.dart' as api;

extension ApiEventCheckInMapper on api.EventCheckIn {
  domain.EventCheckIn toDomain() => domain.EventCheckIn(
    id: id,
    eventID: eventId,
    userID: userId,
    checkedInBy: checkedInBy,
    name: name,
    lastName: lastName,
    email: email,
    createdAt: DateTime.tryParse(createdAt) ?? DateTime.now(),
  );
}
