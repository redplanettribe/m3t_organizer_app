part of 'check_in_event_cubit.dart';

final class CheckInEventState extends Equatable {
  const CheckInEventState({
    this.loading = false,
    this.latestCheckIn,
    this.errorMessage,
    this.lastScannedUserId,
    this.scanFeedbackNonce = 0,
  });

  final bool loading;
  final EventCheckIn? latestCheckIn;
  final String? errorMessage;
  final String? lastScannedUserId;

  /// Bumped when a scan resolves to "already checked in" so listeners can
  /// re-fire transient UI feedback even when [latestCheckIn] is unchanged.
  final int scanFeedbackNonce;

  static const _sentinel = Object();

  CheckInEventState copyWith({
    bool? loading,
    Object? latestCheckIn = _sentinel,
    Object? errorMessage = _sentinel,
    Object? lastScannedUserId = _sentinel,
    int? scanFeedbackNonce,
  }) {
    return CheckInEventState(
      loading: loading ?? this.loading,
      latestCheckIn: latestCheckIn == _sentinel
          ? this.latestCheckIn
          : latestCheckIn as EventCheckIn?,
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
