import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

typedef UserIDDetected = void Function(String userID);

final class EventQrScanner extends StatefulWidget {
  const EventQrScanner({
    required this.onUserIDDetected,
    this.onClose,
    this.enabled = true,
    super.key,
  });

  final UserIDDetected onUserIDDetected;
  final VoidCallback? onClose;
  final bool enabled;

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
      ],
    );
  }
}
