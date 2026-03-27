import 'dart:async' show unawaited;

import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m3t_organizer/features/check_in_event/bloc/bloc.dart';
import 'package:m3t_organizer/features/check_in_event/view/event_qr_scanner.dart';

final class EventCheckInView extends StatelessWidget {
  const EventCheckInView({
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
      child: const _EventCheckInViewBody(),
    );
  }
}

final class _EventCheckInViewBody extends StatelessWidget {
  const _EventCheckInViewBody();

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
          return Column(
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
              child: EventQrScanner<EventCheckIn>(
                enabled: !state.loading,
                lastSuccess: state.latestCheckIn,
                formatSuccessDetail: (checkIn) => formatEventCheckInSuccess(
                  eventCheckInToDisplay(
                    userID: checkIn.userID,
                    name: checkIn.name,
                    lastName: checkIn.lastName,
                    email: checkIn.email,
                  ),
                ),
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
