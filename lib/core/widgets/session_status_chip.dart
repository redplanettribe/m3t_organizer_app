import 'package:domain/domain.dart';
import 'package:flutter/material.dart';

/// Session status as a pill: **Live** shows icon + “Live”; other states are
/// **icon-only** to save space. Use [Tooltip] on long-press / hover for labels.
final class SessionStatusChip extends StatelessWidget {
  const SessionStatusChip({
    required this.status,
    this.compact = false,
    super.key,
  });

  final SessionStatus? status;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    if (status == null) {
      return _StatusPill(
        label: null,
        tooltip: 'Status unknown',
        icon: Icons.help_outline_rounded,
        foreground: scheme.onSurfaceVariant,
        background: scheme.surfaceContainerHighest,
        borderColor: scheme.outlineVariant.withValues(alpha: 0.6),
        compact: compact,
      );
    }

    final s = status!;
    return switch (s) {
      SessionStatus.scheduled => _StatusPill(
        label: null,
        tooltip: 'Scheduled',
        icon: Icons.schedule_rounded,
        foreground: scheme.onSurfaceVariant,
        background: scheme.surfaceContainerHighest,
        borderColor: scheme.outline.withValues(alpha: 0.35),
        compact: compact,
      ),
      SessionStatus.live => _StatusPill(
        label: 'Live',
        tooltip: 'Live now',
        icon: Icons.fiber_manual_record_rounded,
        iconSize: compact ? 10 : 12,
        foreground: scheme.primary,
        background: scheme.primary.withValues(alpha: 0.12),
        borderColor: scheme.primary.withValues(alpha: 0.28),
        compact: compact,
      ),
      SessionStatus.completed => _StatusPill(
        label: null,
        tooltip: 'Completed',
        icon: Icons.check_circle_rounded,
        foreground: scheme.secondary,
        background: scheme.secondary.withValues(alpha: 0.12),
        borderColor: scheme.secondary.withValues(alpha: 0.28),
        compact: compact,
      ),
      SessionStatus.draft => _StatusPill(
        label: null,
        tooltip: 'Draft',
        icon: Icons.edit_rounded,
        foreground: scheme.onSurfaceVariant,
        background: scheme.surfaceContainerHighest,
        borderColor: scheme.outlineVariant.withValues(alpha: 0.6),
        compact: compact,
      ),
      SessionStatus.canceled => _StatusPill(
        label: null,
        tooltip: 'Canceled',
        icon: Icons.block_rounded,
        foreground: scheme.error,
        background: scheme.error.withValues(alpha: 0.12),
        borderColor: scheme.error.withValues(alpha: 0.28),
        compact: compact,
      ),
    };
  }
}

final class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.label,
    required this.tooltip,
    required this.icon,
    required this.foreground,
    required this.background,
    required this.borderColor,
    required this.compact,
    this.iconSize,
  });

  final String? label;
  final String tooltip;
  final IconData icon;
  final Color foreground;
  final Color background;
  final Color borderColor;
  final bool compact;
  final double? iconSize;

  static const double _compactExtent = 32;
  static const double _fullExtent = 40;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final resolvedIconSize = iconSize ??
        (label == null
            ? (compact ? 17.0 : 21.0)
            : (compact ? 10.0 : 12.0));
    final textStyle = compact
        ? theme.textTheme.labelMedium?.copyWith(
            color: foreground,
            fontWeight: FontWeight.w600,
            height: 1.1,
          )
        : theme.textTheme.labelLarge?.copyWith(
            color: foreground,
            fontWeight: FontWeight.w600,
            height: 1.1,
          );

    final extent = compact ? _compactExtent : _fullExtent;

    final Widget pill = DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: borderColor),
      ),
      child: label == null
          ? SizedBox(
              width: extent,
              height: extent,
              child: Center(
                child: Icon(
                  icon,
                  size: resolvedIconSize,
                  color: foreground,
                ),
              ),
            )
          : SizedBox(
              height: extent,
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: compact ? 8 : 12,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, size: resolvedIconSize, color: foreground),
                      SizedBox(width: compact ? 5 : 6),
                      Text(label!, style: textStyle),
                    ],
                  ),
                ),
              ),
            ),
    );

    return Tooltip(
      message: tooltip,
      child: Semantics(
        label: tooltip,
        button: false,
        child: pill,
      ),
    );
  }
}
