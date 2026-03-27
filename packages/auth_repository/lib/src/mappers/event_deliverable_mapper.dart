import 'package:domain/domain.dart' as domain;
import 'package:m3t_api/m3t_api.dart' as api;

extension ApiEventDeliverableMapper on api.EventDeliverable {
  domain.EventDeliverable toDomain() => domain.EventDeliverable(
    id: id,
    name: name,
    description: description,
  );
}
