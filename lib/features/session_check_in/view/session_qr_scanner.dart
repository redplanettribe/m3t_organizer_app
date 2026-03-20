import 'dart:async' show Timer, unawaited;

import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m3t_organizer/features/session_check_in/bloc/bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

typedef UserIDDetected = void Function(String userID);

String _formatSessionCheckInAttendee(SessionCheckIn checkIn) {
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

final class SessionQrScanner extends StatefulWidget {
  const SessionQrScanner({
    required this.onUserIDDetected,
    this.onClose,
    this.enabled = true,
    this.lastSuccessfulCheckIn,
    super.key,
  });

  final UserIDDetected onUserIDDetected;
  final VoidCallback? onClose;
  final bool enabled;
  final SessionCheckIn? lastSuccessfulCheckIn;

  @override
  State<SessionQrScanner> createState() => _SessionQrScannerState();
}

final class _SessionQrScannerState extends State<SessionQrScanner> {
  late final MobileScannerController _controller;
  bool _torchEnabled = false;
  String? _flashMessage;
  bool _flashIsSuccess = true;
  Timer? _flashTimer;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
    );
  }

  @override
  void dispose() {
    _flashTimer?.cancel();
    unawaited(_controller.dispose());
    super.dispose();
  }

  String? _flashDetail;

  void _showFlash(
    String message, {
    required bool success,
    String? detail,
  }) {
    _flashTimer?.cancel();
    setState(() {
      _flashMessage = message;
      _flashDetail = detail;
      _flashIsSuccess = success;
    });
    final duration = detail != null
        ? const Duration(milliseconds: 2200)
        : const Duration(milliseconds: 1400);
    _flashTimer = Timer(duration, () {
      if (!mounted) {
        return;
      }
      setState(() {
        _flashMessage = null;
        _flashDetail = null;
      });
    });
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

    Widget scannerColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                'Check-in an attendee',
                style: theme.textTheme.titleSmall,
              ),
            ),
            if (widget.onClose != null)
              TextButton(
                onPressed: widget.onClose,
                child: const Text('Done'),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          "Position the attendee's QR code inside the frame.",
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        BlocBuilder<SessionCheckInCubit, SessionCheckInState>(
          buildWhen: (previous, current) =>
              previous.lastScannedUserId != current.lastScannedUserId ||
              previous.latestCheckIn?.id != current.latestCheckIn?.id,
          builder: (context, state) {
            final id = state.lastScannedUserId;
            String line;
            if (id == null) {
              line = '—';
            } else if (state.latestCheckIn != null &&
                state.latestCheckIn!.userID == id) {
              line = _formatSessionCheckInAttendee(state.latestCheckIn!);
            } else {
              line = id;
            }
            return Text(
              'Last scan: $line',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            );
          },
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
                if (_flashMessage != null)
                  IgnorePointer(
                    child: ColoredBox(
                      color:
                          _flashIsSuccess ? Colors.black45 : Colors.black38,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _flashIsSuccess
                                    ? Icons.check_circle_rounded
                                    : Icons.info_rounded,
                                size: 48,
                                color: _flashIsSuccess
                                    ? theme.colorScheme.tertiary
                                    : Colors.white,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _flashMessage!,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (_flashDetail != null) ...[
                                const SizedBox(height: 6),
                                Text(
                                  _flashDetail!,
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
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
                '${_formatSessionCheckInAttendee(
                  widget.lastSuccessfulCheckIn!,
                )}',
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
                            _formatSessionCheckInAttendee(
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

    scannerColumn = BlocListener<SessionCheckInCubit, SessionCheckInState>(
      listenWhen: (previous, current) =>
          previous.latestCheckIn?.id != current.latestCheckIn?.id &&
          current.latestCheckIn != null &&
          !current.loading &&
          current.errorMessage == null,
      listener: (context, state) {
        final checkIn = state.latestCheckIn!;
        _showFlash(
          'Checked in',
          success: true,
          detail: _formatSessionCheckInAttendee(checkIn),
        );
      },
      child: scannerColumn,
    );

    scannerColumn = BlocListener<SessionCheckInCubit, SessionCheckInState>(
      listenWhen: (previous, current) =>
          previous.scanFeedbackNonce != current.scanFeedbackNonce &&
          previous.latestCheckIn?.id == current.latestCheckIn?.id,
      listener: (context, state) {
        _showFlash('Already checked in', success: false);
      },
      child: scannerColumn,
    );

    return scannerColumn;
  }
}
