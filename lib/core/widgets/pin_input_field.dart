import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pinput.dart';

/// A centrally-themed, accessible pin/OTP input widget.
///
/// Wraps [Pinput] with M3 [ColorScheme]-derived [PinTheme]s and an
/// [AutofillGroup] so that iOS/Android can autofill codes received via SMS or
/// email whenever [autofillHints] includes [AutofillHints.oneTimeCode].
///
/// ### Examples
///
/// **6-digit numeric OTP (SMS/email autofill + auto-submit):**
/// ```dart
/// PinInputField(
///   length: 6,
///   keyboardType: TextInputType.number,
///   inputFormatters: const [FilteringTextInputFormatter.digitsOnly],
///   onChanged: (v) => bloc.add(LoginCodeChanged(v)),
///   onCompleted: (_) => bloc.add(const LoginCodeSubmitted()),
/// )
/// ```
///
/// **4-character alphanumeric event code (autofill + auto-submit):**
/// ```dart
/// PinInputField(
///   length: 4,
///   keyboardType: TextInputType.text,
///   textCapitalization: TextCapitalization.characters,
///   enableSuggestions: false,
///   inputFormatters: [
///     FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9]')),
///     const _UpperCaseTextFormatter(),
///   ],
///   onChanged: cubit.eventCodeChanged,
///   onCompleted: (_) => cubit.submit(),
/// )
/// ```
///
/// ### Android SMS autofill
/// Pinput's [autofillHints] triggers iOS's QuickType bar automatically.
/// For on-device Android SMS interception you additionally need to pass a
/// [SmsRetriever] (e.g. from the `smart_auth` package). Without it Android
/// still benefits from Autofill Framework when the SMS conforms to the spec.
final class PinInputField extends StatelessWidget {
  const PinInputField({
    required this.length,
    required this.onChanged,
    super.key,
    this.onCompleted,
    this.enabled = true,
    this.autofocus = false,
    this.keyboardType = .number,
    this.textCapitalization = .none,
    // OneTimeCode is the default in Pinput itself; we make it explicit here
    // so callers can override for non-OTP contexts.
    this.autofillHints = const <String>[AutofillHints.oneTimeCode],
    this.inputFormatters = const <TextInputFormatter>[],
    this.enableSuggestions = true,
    this.errorText,
  });

  /// Number of pin cells to display.
  final int length;

  /// Fired on every keystroke with the current value.
  final ValueChanged<String> onChanged;

  /// Fired once when [length] characters have been entered.
  /// The keyboard is closed automatically; auto-submitting here is safe.
  final ValueChanged<String>? onCompleted;

  /// Disables the field when false (e.g. while a network request is in flight).
  final bool enabled;

  /// Whether to request focus when the widget is first built.
  final bool autofocus;

  /// Keyboard type shown when the field is focused.
  final TextInputType keyboardType;

  /// IME capitalisation hint. [TextCapitalization.characters] is useful for
  /// alphanumeric event codes; leave [TextCapitalization.none] for OTPs.
  final TextCapitalization textCapitalization;

  /// Autofill service hints. Defaults to [[AutofillHints.oneTimeCode]].
  final Iterable<String> autofillHints;

  /// Formatters applied to every input event (keyboard, paste, autofill).
  final List<TextInputFormatter> inputFormatters;

  /// Whether to show keyboard suggestions. Set to false for structured codes.
  final bool enableSuggestions;

  /// When non-null the error state theme is applied and this text is shown
  /// below the pin cells.
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final inputTheme = theme.inputDecorationTheme;

    // Read border radius and fill colour from the single source of truth
    // (AppTheme.inputDecorationTheme) so pin cells always match plain fields.
    final pinBorderRadius =
        (inputTheme.border as OutlineInputBorder?)?.borderRadius ??
        const BorderRadius.all(Radius.circular(12));
    final fillColor =
        inputTheme.fillColor ?? colorScheme.surfaceContainerHighest;

    final baseBorder = Border.all(color: colorScheme.outline);
    final baseDecoration = BoxDecoration(
      color: fillColor,
      borderRadius: pinBorderRadius,
      border: baseBorder,
    );

    final baseTheme = PinTheme(
      width: 56,
      height: 60,
      textStyle: textTheme.headlineSmall?.copyWith(
        color: colorScheme.onSurface,
        fontWeight: .w600,
      ),
      decoration: baseDecoration,
    );

    return AutofillGroup(
      child: Pinput(
        length: length,
        enabled: enabled,
        autofocus: autofocus,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization,
        autofillHints: autofillHints,
        inputFormatters: inputFormatters,
        enableSuggestions: enableSuggestions,
        onChanged: onChanged,
        onCompleted: onCompleted,
        hapticFeedbackType: .lightImpact,
        errorText: errorText,
        // ── Themes ──────────────────────────────────────────────────────────
        defaultPinTheme: baseTheme,
        followingPinTheme: baseTheme.copyWith(
          decoration: baseDecoration.copyWith(
            color: colorScheme.surface,
            border: Border.all(color: colorScheme.outlineVariant),
          ),
        ),
        focusedPinTheme: baseTheme.copyWith(
          decoration: baseDecoration.copyWith(
            border: Border.all(color: colorScheme.primary, width: 2),
          ),
        ),
        submittedPinTheme: baseTheme.copyWith(
          decoration: baseDecoration.copyWith(
            color: colorScheme.primaryContainer,
            border: Border.all(color: colorScheme.primary),
          ),
        ),
        errorPinTheme: baseTheme.copyWith(
          decoration: baseDecoration.copyWith(
            border: Border.all(color: colorScheme.error, width: 2),
          ),
        ),
        disabledPinTheme: baseTheme.copyWith(
          decoration: baseDecoration.copyWith(
            color: colorScheme.surfaceContainerLow,
            border: Border.all(color: colorScheme.outlineVariant),
          ),
        ),
      ),
    );
  }
}
