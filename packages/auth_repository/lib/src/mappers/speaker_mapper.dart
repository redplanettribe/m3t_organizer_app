import 'package:domain/domain.dart' as domain;
import 'package:m3t_api/m3t_api.dart' as api;

extension ApiSpeakerMapper on api.Speaker {
  domain.Speaker toDomain() => domain.Speaker(
    id: id,
    firstName: firstName,
    lastName: lastName,
    isTopSpeaker: isTopSpeaker,
  );
}
