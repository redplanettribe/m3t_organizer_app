import 'package:domain/domain.dart' as domain;
import 'package:m3t_api/m3t_api.dart' as api;

extension ApiSessionCheckInMapper on api.SessionCheckIn {
  domain.SessionCheckIn toDomain() => domain.SessionCheckIn(
    id: id,
    sessionID: sessionId,
    userID: userId,
    checkedInBy: checkedInBy,
    createdAt: DateTime.tryParse(createdAt) ?? DateTime.now(),
  );
}
