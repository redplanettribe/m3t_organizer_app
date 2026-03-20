import 'dart:async' show unawaited;

import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

typedef UserIDDetected = void Function(String userID);

String _formatEventCheckInAttendee(EventCheckIn checkIn) {
  final first = checkIn.name?.trim();
  final last = checkIn.lastName?.trim();
  final parts = <String>[];
  if (first != null && first.isNotEmpty) {
    parts.add(first);
  }
  if (last != null && last.isNotEmpty) {
    parts.add(last);
  }
  if (parts.isNotEmpty) {
    return parts.join(' ');
  }
  final email = checkIn.email?.trim();
  if (email != null && email.isNotEmpty) {
    return email;
  }
  return checkIn.userID;
}

final class EventQrScanner extends StatefulWidget {
  const EventQrScanner({
    required this.onUserIDDetected,
    this.onClose,
    this.enabled = true,
    this.lastSuccessfulCheckIn,
    super.key,
  });

  final UserIDDetected onUserIDDetected;
  final VoidCallback? onClose;
  final bool enabled;
  final EventCheckIn? lastSuccessfulCheckIn;

  @override
  State<EventQrScanner> createState() => _EventQrScannerState();
}

final class _EventQrScannerState extends State<EventQrScanner> {
  late final MobileScannerController _controller;
  bool _torchEnabled = false;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
    );
  }

  @override
  void dispose() {
    unawaited(_controller.dispose());
    super.dispose();
  }

  Future<void> _toggleTorch() async {
    await _controller.toggleTorch();
    if (!mounted) {
      return;
    }
    setState(() {
      _torchEnabled = !_torchEnabled;
    });
  }

  void _onDetect(BarcodeCapture capture) {
    if (!widget.enabled) {
      return;
    }

    for (final barcode in capture.barcodes) {
      final rawValue = barcode.rawValue;
      if (rawValue == null || rawValue.trim().isEmpty) {
        continue;
      }

      widget.onUserIDDetected(rawValue.trim());
      break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.onClose != null)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  'Check-in an attendee',
                  style: theme.textTheme.titleSmall,
                ),
              ),
              TextButton(
                onPressed: widget.onClose,
                child: const Text('Done'),
              ),
            ],
          )
        else
          Text(
            'Check-in an attendee',
            style: theme.textTheme.titleMedium,
          ),
        const SizedBox(height: 4),
        Text(
          "Position the attendee's QR code inside the frame.",
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 280,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              fit: StackFit.expand,
              children: [
                MobileScanner(
                  controller: _controller,
                  onDetect: _onDetect,
                ),
                IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: theme.colorScheme.primary.withValues(
                          alpha: 0.85,
                        ),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                Positioned(
                  left: 12,
                  right: 12,
                  bottom: 12,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FilledButton.tonalIcon(
                        onPressed: _toggleTorch,
                        icon: Icon(
                          _torchEnabled
                              ? Icons.flash_on_rounded
                              : Icons.flash_off_rounded,
                        ),
                        label: Text(_torchEnabled ? 'Flash on' : 'Flash off'),
                      ),
                    ],
                  ),
                ),
                if (!widget.enabled)
                  ColoredBox(
                    color: Colors.black45,
                    child: Center(
                      child: Text(
                        'Processing check-in...',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (widget.enabled && widget.lastSuccessfulCheckIn != null) ...[
          const SizedBox(height: 12),
          Semantics(
            liveRegion: true,
            label: 'Checked in '
                '${_formatEventCheckInAttendee(widget.lastSuccessfulCheckIn!)}',
            child: Material(
              color: theme.colorScheme.tertiaryContainer,
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
                      Icons.check_circle_rounded,
                      color: theme.colorScheme.onTertiaryContainer,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Checked in',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: theme.colorScheme.onTertiaryContainer,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _formatEventCheckInAttendee(
                              widget.lastSuccessfulCheckIn!,
                            ),
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onTertiaryContainer,
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
