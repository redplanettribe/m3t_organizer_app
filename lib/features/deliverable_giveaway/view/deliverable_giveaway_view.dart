import 'dart:async' show unawaited;

import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m3t_organizer/features/deliverable_giveaway/bloc/bloc.dart';
import 'package:m3t_organizer/features/deliverable_giveaway/view/deliverable_giveaway_scanner.dart';

final class DeliverableGiveawayView extends StatelessWidget {
  const DeliverableGiveawayView({
    required this.eventID,
    super.key,
  });

  final String eventID;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = DeliverableGiveawayCubit(
          eventID: eventID,
          eventsRepository: context.read<EventsRepository>(),
        );
        unawaited(cubit.loadDeliverables());
        return cubit;
      },
      child: const _DeliverableGiveawayBody(),
    );
  }
}

final class _DeliverableGiveawayBody extends StatelessWidget {
  const _DeliverableGiveawayBody();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<DeliverableGiveawayCubit, DeliverableGiveawayState>(
      listenWhen: (previous, current) =>
          previous.errorMessage != current.errorMessage &&
          current.errorMessage != null,
      listener: (context, state) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              behavior: SnackBarBehavior.floating,
            ),
          );
      },
      child: BlocListener<DeliverableGiveawayCubit, DeliverableGiveawayState>(
        listenWhen: (previous, current) =>
            current.pendingGiveawayRetryUserID != null &&
            current.pendingGiveawayRetryUserID !=
                previous.pendingGiveawayRetryUserID,
        listener: (context, state) {
          final userID = state.pendingGiveawayRetryUserID!;
          unawaited(_showGiveAnywayDialog(context, userID));
        },
        child: BlocBuilder<DeliverableGiveawayCubit, DeliverableGiveawayState>(
          builder: (context, state) {
            final cubit = context.read<DeliverableGiveawayCubit>();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Give a deliverable',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Select an item, then scan the attendee’s QR code.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                if (state.loadingList)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (state.deliverables.isEmpty)
                  Text(
                    'No deliverables are set up for this event yet.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  )
                else
                  InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Deliverable',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<EventDeliverable>(
                        isExpanded: true,
                        value: state.selectedDeliverable,
                        hint: const Text('Choose one'),
                        items: state.deliverables
                            .map(
                              (d) => DropdownMenuItem<EventDeliverable>(
                                value: d,
                                child: Text(
                                  d.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: cubit.selectDeliverable,
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: state.loadingList ||
                          state.selectedDeliverable == null ||
                          state.loadingGiveaway
                      ? null
                      : () => _openGiveawayScannerModal(context),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                    shadowColor: Colors.transparent,
                  ),
                  icon: Icon(
                    Icons.qr_code_scanner_rounded,
                    size: 22,
                    color: theme.colorScheme.onPrimary,
                  ),
                  label: Text(
                    state.loadingGiveaway
                        ? 'Recording…'
                        : 'Scan recipient QR',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

Future<void> _showGiveAnywayDialog(BuildContext context, String userID) async {
  final cubit = context.read<DeliverableGiveawayCubit>();
  final item = cubit.state.selectedDeliverable?.name.trim();
  final itemLabel = (item != null && item.isNotEmpty) ? item : 'this item';

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Already delivered'),
        content: Text(
          'This attendee already received $itemLabel. '
          'Record another giveaway anyway?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Give anyway'),
          ),
        ],
      );
    },
  );

  if (!context.mounted) {
    return;
  }
  if (confirmed ?? false) {
    await cubit.submitGiveWithGiveAnyway(userID: userID);
  } else {
    cubit.clearPendingGiveawayRetry();
  }
}

Future<void> _openGiveawayScannerModal(BuildContext context) {
  context.read<DeliverableGiveawayCubit>().clearGiveawayScanError();
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (sheetContext) {
      return BlocProvider.value(
        value: context.read<DeliverableGiveawayCubit>(),
        child: BlocBuilder<DeliverableGiveawayCubit, DeliverableGiveawayState>(
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: DeliverableGiveawayScanner(
                enabled: !state.loadingGiveaway &&
                    state.pendingGiveawayRetryUserID == null,
                lastGiveaway: state.latestGiveaway,
                scanErrorMessage: state.giveawayScanError,
                onClose: () => Navigator.of(sheetContext).pop(),
                onUserIDDetected: (userID) {
                  unawaited(
                    context.read<DeliverableGiveawayCubit>().onUserIDScanned(
                      userID,
                    ),
                  );
                },
              ),
            );
          },
        ),
      );
    },
  );
}
