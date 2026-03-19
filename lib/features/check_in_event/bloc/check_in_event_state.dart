part of 'check_in_event_cubit.dart';

final class CheckInEventState extends Equatable {
  const CheckInEventState({
    this.loading = false,
    this.latestCheckIn,
    this.errorMessage,
  });

  final bool loading;
  final EventCheckIn? latestCheckIn;
  final String? errorMessage;

  static const _sentinel = Object();

  CheckInEventState copyWith({
    bool? loading,
    Object? latestCheckIn = _sentinel,
    Object? errorMessage = _sentinel,
  }) {
    return CheckInEventState(
      loading: loading ?? this.loading,
      latestCheckIn: latestCheckIn == _sentinel
          ? this.latestCheckIn
          : latestCheckIn as EventCheckIn?,
      errorMessage: errorMessage == _sentinel
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  @override
  List<Object?> get props => [loading, latestCheckIn, errorMessage];
}
