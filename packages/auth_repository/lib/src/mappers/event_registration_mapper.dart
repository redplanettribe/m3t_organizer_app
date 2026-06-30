import 'package:domain/domain.dart' as domain;
import 'package:m3t_api/m3t_api.dart' as api;

extension ApiEventRegistrationMapper on api.EventRegistration {
  domain.EventRegistration toDomain() => domain.EventRegistration(
    registrationId: registrationId,
    eventId: eventId,
    userId: userId,
    name: name,
    lastName: lastName,
    email: email,
    checkedIn: checkedIn,
    tierName: tier?.name,
  );
}

extension ApiEventRegistrationPageMapper on api.EventRegistrationPage {
  domain.EventRegistrationPage toDomain() => domain.EventRegistrationPage(
    items: items.map((r) => r.toDomain()).toList(),
    page: pagination?.page,
    pageSize: pagination?.pageSize,
    total: pagination?.total,
    totalPages: pagination?.totalPages,
  );
}
