import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:m3t_organizer/features/check_in_event/view/event_qr_scanner.dart';

/// Formats success copy: `{item} delivered to {recipient}`.
String formatDeliverableGiveawaySuccess(DeliverableGiveaway giveaway) {
  final recipient = formatEventCheckInSuccess(
    eventCheckInToDisplay(
      userID: giveaway.userID,
      name: giveaway.name,
      lastName: giveaway.lastName,
      email: giveaway.email,
    ),
  );
  final item = giveaway.deliverableName?.trim();
  if (item != null && item.isNotEmpty) {
    return '$item delivered to $recipient.';
  }
  return 'Delivered to $recipient.';
}

/// QR flow aligned with [EventQrScanner] / event check-in: camera, torch, feedback cards.
final class DeliverableGiveawayScanner extends StatelessWidget {
  const DeliverableGiveawayScanner({
    required this.enabled,
    required this.lastGiveaway,
    required this.scanErrorMessage,
    required this.onUserIDDetected,
    this.onClose,
    super.key,
  });

  final bool enabled;
  final DeliverableGiveaway? lastGiveaway;
  final String? scanErrorMessage;
  final UserIDDetected onUserIDDetected;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final errorText = scanErrorMessage?.trim();
    final showError = errorText != null && errorText.isNotEmpty;
    final isAlreadyDelivered = errorText
            ?.toLowerCase()
            .contains('already delivered') ??
        false;
    final scannerEnabled = enabled && !isAlreadyDelivered;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        EventQrScanner<DeliverableGiveaway>(
          title: 'Give deliverable',
          processingLabel: 'Recording giveaway…',
          successHeading: 'Delivered',
          semanticsSuccessPrefix: 'Delivered ',
          enabled: scannerEnabled,
          lastSuccess: lastGiveaway,
          formatSuccessDetail: formatDeliverableGiveawaySuccess,
          onClose: onClose,
          onUserIDDetected: onUserIDDetected,
        ),
        if (showError) ...[
          const SizedBox(height: 12),
          Semantics(
            liveRegion: true,
            label: 'Giveaway error: $errorText',
            child: Material(
              color: theme.colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      color: theme.colorScheme.onErrorContainer,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Could not record',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: theme.colorScheme.onErrorContainer,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            errorText,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onErrorContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
