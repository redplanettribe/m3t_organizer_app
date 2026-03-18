import 'dart:async';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screen_brightness/screen_brightness.dart';

/// Shows a full-screen bottom sheet containing a large QR code.
///
/// Call this when the user taps the compact QR card so they can present
/// an easily scannable version at check-in. The sheet displays a padded
/// QR code sized to fill the available width and a brief instructional
/// label.
void showUserQrCodeSheet(BuildContext context, {required String userId}) {
  unawaited(
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => _QrCodeSheet(userId: userId),
    ),
  );
}

// ---------------------------------------------------------------------------
// Private
// ---------------------------------------------------------------------------

final class _QrCodeSheet extends StatefulWidget {
  const _QrCodeSheet({required this.userId});

  final String userId;

  @override
  State<_QrCodeSheet> createState() => _QrCodeSheetState();
}

final class _QrCodeSheetState extends State<_QrCodeSheet> {
  @override
  void initState() {
    super.initState();
    // Maximise brightness while the QR code is visible so scanners at
    // event check-in can read it reliably regardless of ambient light.
    // Errors are swallowed — brightness boost is a UX enhancement, not
    // a hard requirement. The OS may also cap this (e.g. Low Power Mode
    // on iOS). resetApplicationScreenBrightness() in dispose() guarantees
    // the original level is always restored, even on error.
    unawaited(
      ScreenBrightness.instance
          .setApplicationScreenBrightness(1)
          .onError((_, _) => Future<void>.value()),
    );
  }

  @override
  void dispose() {
    unawaited(
      ScreenBrightness.instance.resetApplicationScreenBrightness().onError(
        (_, _) => Future<void>.value(),
      ),
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const .fromLTRB(32, 16, 32, 32),
      child: Column(
        children: [
          Text('Show at check-in', style: textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            'Have the event staff scan this code to confirm your '
            'registration.',
            style: textTheme.bodyMedium,
            textAlign: .center,
          ),
          const SizedBox(height: 32),
          // Fill the available width minus padding for max scan-distance.
          LayoutBuilder(
            builder: (_, constraints) => _UserQrCode(
              userId: widget.userId,
              size: constraints.maxWidth,
            ),
          ),
          const SizedBox(height: 24),
          TextButton(
            style: TextButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
            onPressed: Navigator.of(context).pop,
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

/// Renders a QR code that encodes [userId].
///
/// Colours are intentionally hard-coded to black-on-white regardless of
/// the active theme: the entire ecosystem of QR readers — firmware
/// decoders, cheap barcode guns, web-based scanners — is calibrated
/// against dark-on-light high-contrast images. Inverted palettes reduce
/// reliability on modern readers and can fail entirely on older hardware.
///
/// Error correction level H tolerates ~30 % damage — suitable for event
/// environments with lanyards, glare, or partial screen obstruction.
final class _UserQrCode extends StatelessWidget {
  const _UserQrCode({
    required this.userId,
    this.size = _defaultSize,
  });

  final String userId;

  /// Side length of the rendered QR image in logical pixels.
  final double size;

  static const double _defaultSize = 200;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label:
          'QR code for attendee identity. Show this to be scanned at '
          'event check-in.',
      excludeSemantics: true,
      child: QrImageView(
        data: userId,
        size: size,
        padding: const .all(16),
        errorCorrectionLevel: QrErrorCorrectLevel.H,
        backgroundColor: Colors.white,
      ),
    );
  }
}
