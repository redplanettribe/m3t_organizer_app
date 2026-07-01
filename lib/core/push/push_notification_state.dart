part of 'push_notification_cubit.dart';

final class PushNotificationState extends Equatable {
  const PushNotificationState({this.pendingNavigation});

  final PushNavigationIntent? pendingNavigation;

  static const _sentinel = Object();

  PushNotificationState copyWith({
    PushNavigationIntent? pendingNavigation,
    Object? clearPendingNavigation = _sentinel,
  }) {
    return PushNotificationState(
      pendingNavigation: clearPendingNavigation == _sentinel
          ? pendingNavigation ?? this.pendingNavigation
          : null,
    );
  }

  @override
  List<Object?> get props => [pendingNavigation];
}
