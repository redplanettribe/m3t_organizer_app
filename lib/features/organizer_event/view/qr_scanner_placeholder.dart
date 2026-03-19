import 'package:flutter/material.dart';

final class QrScannerPlaceholder extends StatelessWidget {
  const QrScannerPlaceholder({
    required this.title,
    required this.subtitle,
    this.compact = false,
    super.key,
  });

  final String title;
  final String subtitle;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final frameHeight = compact ? 180.0 : 260.0;
    final textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: frameHeight,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.45,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Stack(
            children: [
              Center(
                child: Container(
                  width: compact ? 130 : 200,
                  height: compact ? 130 : 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: theme.colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  child: const Icon(Icons.qr_code_scanner_rounded, size: 54),
                ),
              ),
              const Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    _DisabledActionChip(
                      icon: Icons.flash_off_rounded,
                      label: 'Flash',
                    ),
                    _DisabledActionChip(
                      icon: Icons.pause_circle_outline_rounded,
                      label: 'Stop',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

final class _DisabledActionChip extends StatelessWidget {
  const _DisabledActionChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
