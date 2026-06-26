import 'dart:async' show unawaited;

import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m3t_organizer/features/session_check_in/bloc/bloc.dart';
import 'package:m3t_organizer/features/session_check_in/view/session_qr_scanner.dart';

/// Top-of-tab control that hosts [SessionCheckInCubit] and opens the QR
/// scanner.
final class SessionCheckInButton extends StatelessWidget {
  const SessionCheckInButton({
    required this.eventID,
    required this.sessionID,
    super.key,
  });

  final String eventID;
  final String sessionID;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      key: ValueKey<String>('session-check-in-$eventID-$sessionID'),
      create: (_) => SessionCheckInCubit(
        eventID: eventID,
        sessionID: sessionID,
        eventsRepository: context.read<EventsRepository>(),
      ),
      child: BlocBuilder<SessionCheckInCubit, SessionCheckInState>(
        builder: (context, state) {
          final theme = Theme.of(context);

          return FilledButton.icon(
            onPressed: state.loading ? null : () => _openScannerModal(context),
            icon: const Icon(
              Icons.qr_code_scanner_rounded,
              size: 22,
            ),
            label: Text(
              state.loading ? 'Checking in…' : 'Scan attendee QR',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        },
      ),
    );
  }
}

Future<void> _openScannerModal(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (sheetContext) {
      return BlocProvider.value(
        value: context.read<SessionCheckInCubit>(),
        child: BlocBuilder<SessionCheckInCubit, SessionCheckInState>(
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: SessionQrScanner(
                enabled: !state.loading,
                lastSuccessfulCheckIn: state.latestCheckIn,
                onClose: () => Navigator.of(sheetContext).pop(),
                onUserIDDetected: (userID) {
                  unawaited(
                    context.read<SessionCheckInCubit>().onUserIDScanned(userID),
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
