part of 'session_status_cubit.dart';

final class SessionStatusState extends Equatable {
  const SessionStatusState({
    this.loading = false,
    this.updating = false,
    this.session,
    this.errorMessage,
  });

  final bool loading;
  final bool updating;
  final Session? session;
  final String? errorMessage;

  static const _sentinel = Object();

  SessionStatusState copyWith({
    bool? loading,
    bool? updating,
    Object? session = _sentinel,
    Object? errorMessage = _sentinel,
  }) {
    return SessionStatusState(
      loading: loading ?? this.loading,
      updating: updating ?? this.updating,
      session: session == _sentinel ? this.session : session as Session?,
      errorMessage: errorMessage == _sentinel
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  @override
  List<Object?> get props => [
    loading,
    updating,
    session,
    errorMessage,
  ];
}
