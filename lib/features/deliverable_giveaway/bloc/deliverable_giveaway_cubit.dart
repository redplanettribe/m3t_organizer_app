import 'package:domain/domain.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m3t_organizer/core/events/events_failure_message.dart';
import 'package:m3t_organizer/features/deliverable_giveaway/bloc/deliverable_giveaway_failure_message.dart';

part 'deliverable_giveaway_state.dart';

final class DeliverableGiveawayCubit extends Cubit<DeliverableGiveawayState> {
  DeliverableGiveawayCubit({
    required String eventID,
    required EventsRepository eventsRepository,
  }) : _eventID = eventID,
       _eventsRepository = eventsRepository,
       super(const DeliverableGiveawayState());

  final String _eventID;
  final EventsRepository _eventsRepository;

  DateTime? _lastScanAt;
  String? _lastScannedUserID;

  static const _duplicateScanCooldown = Duration(seconds: 2);

  Future<void> loadDeliverables() async {
    emit(
      state.copyWith(
        loadingList: true,
        errorMessage: null,
      ),
    );

    try {
      final list = await _eventsRepository.getEventDeliverables(
        eventID: _eventID,
      );
      final selected = state.selectedDeliverable;
      final stillValid = selected != null &&
          list.any((d) => d.id == selected.id);
      emit(
        state.copyWith(
          loadingList: false,
          deliverables: list,
          selectedDeliverable: stillValid ? selected : null,
          errorMessage: null,
        ),
      );
    } on EventsFailure catch (failure, stackTrace) {
      addError(failure, stackTrace);
      emit(
        state.copyWith(
          loadingList: false,
          errorMessage: failure.toDeliverableGiveawayLoadMessage(),
        ),
      );
    } on Object catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(
        state.copyWith(
          loadingList: false,
          errorMessage: EventsUnknownError().toDisplayMessage(),
        ),
      );
    }
  }

  void selectDeliverable(EventDeliverable? deliverable) {
    emit(state.copyWith(selectedDeliverable: deliverable));
  }

  void clearGiveawayScanError() {
    if (state.giveawayScanError == null &&
        state.pendingGiveawayRetryUserID == null) {
      return;
    }
    emit(
      state.copyWith(
        giveawayScanError: null,
        pendingGiveawayRetryUserID: null,
      ),
    );
  }

  void clearPendingGiveawayRetry() {
    if (state.pendingGiveawayRetryUserID == null) {
      return;
    }
    emit(state.copyWith(pendingGiveawayRetryUserID: null));
  }

  Future<void> onUserIDScanned(String userID) async {
    final normalizedUserID = userID.trim();
    final deliverable = state.selectedDeliverable;
    if (normalizedUserID.isEmpty ||
        state.loadingGiveaway ||
        deliverable == null) {
      return;
    }

    final now = DateTime.now();
    if (_lastScannedUserID == normalizedUserID &&
        _lastScanAt != null &&
        now.difference(_lastScanAt!) < _duplicateScanCooldown) {
      return;
    }

    _lastScannedUserID = normalizedUserID;
    _lastScanAt = now;
    emit(
      state.copyWith(
        loadingGiveaway: true,
        giveawayScanError: null,
        latestGiveaway: null,
        pendingGiveawayRetryUserID: null,
      ),
    );

    try {
      final giveaway = await _eventsRepository.giveDeliverableToUser(
        eventID: _eventID,
        deliverableID: deliverable.id,
        userID: normalizedUserID,
      );
      final latest = _giveawayWithItemName(giveaway, deliverable.name);
      emit(
        state.copyWith(
          loadingGiveaway: false,
          latestGiveaway: latest,
          giveawayScanError: null,
        ),
      );
    } on EventsFailure catch (failure, stackTrace) {
      addError(failure, stackTrace);
      if (failure is EventsDeliverableAlreadyGiven) {
        _lastScannedUserID = null;
        _lastScanAt = null;
        emit(
          state.copyWith(
            loadingGiveaway: false,
            giveawayScanError: null,
            pendingGiveawayRetryUserID: normalizedUserID,
          ),
        );
        return;
      }
      emit(
        state.copyWith(
          loadingGiveaway: false,
          giveawayScanError: failure.toDeliverableGiveawayScanMessage(),
        ),
      );
    } on Object catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(
        state.copyWith(
          loadingGiveaway: false,
          giveawayScanError: EventsUnknownError().toDisplayMessage(),
        ),
      );
    }
  }

  DeliverableGiveaway _giveawayWithItemName(
    DeliverableGiveaway giveaway,
    String itemName,
  ) {
    final existing = giveaway.deliverableName?.trim();
    if (existing != null && existing.isNotEmpty) {
      return giveaway;
    }
    final trimmed = itemName.trim();
    if (trimmed.isEmpty) {
      return giveaway;
    }
    return DeliverableGiveaway(
      id: giveaway.id,
      eventID: giveaway.eventID,
      deliverableID: giveaway.deliverableID,
      userID: giveaway.userID,
      givenBy: giveaway.givenBy,
      name: giveaway.name,
      lastName: giveaway.lastName,
      email: giveaway.email,
      deliverableName: trimmed,
      createdAt: giveaway.createdAt,
    );
  }

  /// Retries giveaway for [userID] with API `give_anyway` set (after HTTP 409).
  Future<void> submitGiveWithGiveAnyway({required String userID}) async {
    final deliverable = state.selectedDeliverable;
    final normalized = userID.trim();
    if (normalized.isEmpty || state.loadingGiveaway || deliverable == null) {
      return;
    }

    emit(
      state.copyWith(
        loadingGiveaway: true,
        giveawayScanError: null,
        latestGiveaway: null,
        pendingGiveawayRetryUserID: null,
      ),
    );

    try {
      final giveaway = await _eventsRepository.giveDeliverableToUser(
        eventID: _eventID,
        deliverableID: deliverable.id,
        userID: normalized,
        giveAnyway: true,
      );
      final latest = _giveawayWithItemName(giveaway, deliverable.name);
      emit(
        state.copyWith(
          loadingGiveaway: false,
          latestGiveaway: latest,
          giveawayScanError: null,
        ),
      );
    } on EventsFailure catch (failure, stackTrace) {
      addError(failure, stackTrace);
      emit(
        state.copyWith(
          loadingGiveaway: false,
          giveawayScanError: failure.toDeliverableGiveawayScanMessage(),
        ),
      );
    } on Object catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(
        state.copyWith(
          loadingGiveaway: false,
          giveawayScanError: EventsUnknownError().toDisplayMessage(),
        ),
      );
    }
  }
}
