part of 'session_check_in_cubit.dart';

final class SessionCheckInState extends Equatable {
  const SessionCheckInState({
    this.loading = false,
    this.latestCheckIn,
    this.errorMessage,
    this.lastScannedUserId,
    this.scanFeedbackNonce = 0,
  });

  final bool loading;
  final SessionCheckIn? latestCheckIn;
  final String? errorMessage;
  final String? lastScannedUserId;
  final int scanFeedbackNonce;

  static const _sentinel = Object();

  SessionCheckInState copyWith({
    bool? loading,
    Object? latestCheckIn = _sentinel,
    Object? errorMessage = _sentinel,
    Object? lastScannedUserId = _sentinel,
    int? scanFeedbackNonce,
  }) {
    return SessionCheckInState(
      loading: loading ?? this.loading,
      latestCheckIn: latestCheckIn == _sentinel
          ? this.latestCheckIn
          : latestCheckIn as SessionCheckIn?,
      errorMessage: errorMessage == _sentinel
          ? this.errorMessage
          : errorMessage as String?,
      lastScannedUserId: lastScannedUserId == _sentinel
          ? this.lastScannedUserId
          : lastScannedUserId as String?,
      scanFeedbackNonce: scanFeedbackNonce ?? this.scanFeedbackNonce,
    );
  }

  @override
  List<Object?> get props => [
    loading,
    latestCheckIn,
    errorMessage,
    lastScannedUserId,
    scanFeedbackNonce,
  ];
}
