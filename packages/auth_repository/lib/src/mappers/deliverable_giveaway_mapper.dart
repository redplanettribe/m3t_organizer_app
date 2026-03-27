import 'package:domain/domain.dart' as domain;
import 'package:m3t_api/m3t_api.dart' as api;

extension ApiDeliverableGiveawayMapper on api.DeliverableGiveaway {
  domain.DeliverableGiveaway toDomain() {
    final u = user;
    return domain.DeliverableGiveaway(
      id: id,
      eventID: eventId,
      deliverableID: deliverableId,
      userID: userId,
      givenBy: givenBy,
      name: name ?? u?.name,
      lastName: lastName ?? u?.lastName,
      email: email ?? u?.email,
      deliverableName: deliverableName,
      createdAt: DateTime.tryParse(createdAt) ?? DateTime.now(),
    );
  }
}
