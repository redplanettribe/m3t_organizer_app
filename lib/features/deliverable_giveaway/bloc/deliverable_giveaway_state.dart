part of 'deliverable_giveaway_cubit.dart';

final class DeliverableGiveawayState extends Equatable {
  const DeliverableGiveawayState({
    this.deliverables = const [],
    this.selectedDeliverable,
    this.loadingList = false,
    this.loadingGiveaway = false,
    this.latestGiveaway,
    this.errorMessage,
    this.giveawayScanError,
    this.pendingGiveawayRetryUserID,
  });

  final List<EventDeliverable> deliverables;
  final EventDeliverable? selectedDeliverable;
  final bool loadingList;
  final bool loadingGiveaway;
  final DeliverableGiveaway? latestGiveaway;
  final String? errorMessage;
  /// Shown inline on the giveaway scanner (not the deliverable list).
  final String? giveawayScanError;
  /// Set when the API returns 409; UI shows “give anyway?” for this user.
  final String? pendingGiveawayRetryUserID;

  static const _sentinel = Object();

  DeliverableGiveawayState copyWith({
    List<EventDeliverable>? deliverables,
    Object? selectedDeliverable = _sentinel,
    bool? loadingList,
    bool? loadingGiveaway,
    Object? latestGiveaway = _sentinel,
    Object? errorMessage = _sentinel,
    Object? giveawayScanError = _sentinel,
    Object? pendingGiveawayRetryUserID = _sentinel,
  }) {
    return DeliverableGiveawayState(
      deliverables: deliverables ?? this.deliverables,
      selectedDeliverable: selectedDeliverable == _sentinel
          ? this.selectedDeliverable
          : selectedDeliverable as EventDeliverable?,
      loadingList: loadingList ?? this.loadingList,
      loadingGiveaway: loadingGiveaway ?? this.loadingGiveaway,
      latestGiveaway: latestGiveaway == _sentinel
          ? this.latestGiveaway
          : latestGiveaway as DeliverableGiveaway?,
      errorMessage: errorMessage == _sentinel
          ? this.errorMessage
          : errorMessage as String?,
      giveawayScanError: giveawayScanError == _sentinel
          ? this.giveawayScanError
          : giveawayScanError as String?,
      pendingGiveawayRetryUserID: pendingGiveawayRetryUserID == _sentinel
          ? this.pendingGiveawayRetryUserID
          : pendingGiveawayRetryUserID as String?,
    );
  }

  @override
  List<Object?> get props => [
    deliverables,
    selectedDeliverable,
    loadingList,
    loadingGiveaway,
    latestGiveaway,
    errorMessage,
    giveawayScanError,
    pendingGiveawayRetryUserID,
  ];
}
