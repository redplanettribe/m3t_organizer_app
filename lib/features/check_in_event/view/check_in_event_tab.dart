import 'dart:async' show unawaited;

import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m3t_organizer/features/check_in_event/bloc/bloc.dart';
import 'package:m3t_organizer/features/check_in_event/view/event_qr_scanner.dart';

final class CheckInEventTab extends StatelessWidget {
  const CheckInEventTab({
    required this.eventID,
    super.key,
  });

  final String eventID;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CheckInEventCubit(
        eventID: eventID,
        eventsRepository: context.read<EventsRepository>(),
      ),
      child: const _CheckInEventTabView(),
    );
  }
}

final class _CheckInEventTabView extends StatelessWidget {
  const _CheckInEventTabView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<CheckInEventCubit, CheckInEventState>(
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
      child: BlocBuilder<CheckInEventCubit, CheckInEventState>(
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FilledButton.icon(
                  onPressed: state.loading
                      ? null
                      : () => _openEventScannerModal(context),
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
                    state.loading ? 'Checking in…' : 'Scan attendee QR',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

Future<void> _openEventScannerModal(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (sheetContext) {
      return BlocProvider.value(
        value: context.read<CheckInEventCubit>(),
        child: BlocBuilder<CheckInEventCubit, CheckInEventState>(
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: EventQrScanner(
                enabled: !state.loading,
                onClose: () => Navigator.of(sheetContext).pop(),
                onUserIDDetected: (userID) {
                  unawaited(
                    context.read<CheckInEventCubit>().onUserIDScanned(userID),
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
