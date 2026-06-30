part of 'attendee_registration_cubit.dart';

enum AttendeeRegistrationStatus {
  initial,
  loading,
  ready,
  notFound,
  failure,
}

final class AttendeeRegistrationState extends Equatable {
  const AttendeeRegistrationState({
    this.status = AttendeeRegistrationStatus.initial,
    this.registration,
    this.errorMessage,
  });

  final AttendeeRegistrationStatus status;
  final EventRegistration? registration;
  final String? errorMessage;

  static const _sentinel = Object();

  AttendeeRegistrationState copyWith({
    AttendeeRegistrationStatus? status,
    Object? registration = _sentinel,
    Object? errorMessage = _sentinel,
  }) {
    return AttendeeRegistrationState(
      status: status ?? this.status,
      registration: registration == _sentinel
          ? this.registration
          : registration as EventRegistration?,
      errorMessage: errorMessage == _sentinel
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  @override
  List<Object?> get props => [status, registration, errorMessage];
}
