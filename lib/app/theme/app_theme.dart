import 'package:flutter/material.dart';

/// Single source of truth for all application theming.
///
/// Both [light] and [dark] are built from the same [_seedColor], which M3's
/// `ColorScheme.fromSeed` uses to generate the full tonal palette. Every
/// subsystem that needs colour or shape values derives them from the resulting
/// [ColorScheme] — no hard-coded hex or raw values elsewhere in the app.
///
/// ## Shape tokens
/// Two radius tokens are defined here, each mapping to an M3 shape role:
/// - [inputBorderRadius] — 12dp (`medium`): tight, dense input surfaces.
/// - [cardBorderRadius] — 16dp (`large`): softer container surfaces (cards).
///
/// The intentional difference (12 vs 16) creates a visual hierarchy: inputs
/// feel precise, cards feel spacious. Both values are M3 canonical — changing
/// one does not require changing the other.
///
/// ## Text-input contract
/// [_inputDecorationTheme] drives **all** text-input surfaces:
/// - Every [TextField] / [TextFormField] in the app inherits this style
///   automatically — no per-widget decoration overrides needed.
/// - `PinInputField` reads [ThemeData.inputDecorationTheme] at build time
///   (border radius and fill colour) so pin cells always match plain fields.
///   Any change here propagates to both surfaces with zero extra work.
abstract final class AppTheme {
  static const Color _seedColor = Colors.deepPurple;

  /// Border radius for all input surfaces — M3 `medium` shape token (12dp).
  ///
  /// Exposed so `PinInputField` can read it directly from the built theme
  /// rather than referencing this class, keeping the coupling one-directional.
  static const BorderRadius inputBorderRadius = BorderRadius.all(
    Radius.circular(12),
  );

  /// Border radius for card/container surfaces — M3 `large` shape token (16dp).
  ///
  /// Intentionally higher than [inputBorderRadius]: cards are softer, more
  /// spacious surfaces; inputs are denser and more precise.
  static const BorderRadius cardBorderRadius = BorderRadius.all(
    Radius.circular(16),
  );

  /// Light [ThemeData].
  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(seedColor: _seedColor);
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      inputDecorationTheme: _inputDecorationTheme(colorScheme),
      cardTheme: _cardTheme(colorScheme),
    );
  }

  /// Dark [ThemeData].
  static ThemeData dark() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.dark,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      inputDecorationTheme: _inputDecorationTheme(colorScheme),
      cardTheme: _cardTheme(colorScheme),
    );
  }

  /// Builds the [InputDecorationTheme] that is shared by both light and dark
  /// themes. All state variants are declared explicitly — no implicit fallback
  /// chains that differ across Flutter versions.
  static InputDecorationTheme _inputDecorationTheme(ColorScheme colorScheme) {
    OutlineInputBorder outline(BorderSide side) => OutlineInputBorder(
      borderRadius: inputBorderRadius,
      borderSide: side,
    );

    return InputDecorationTheme(
      filled: true,
      fillColor: colorScheme.surfaceContainerHighest,
      border: outline(BorderSide(color: colorScheme.outline)),
      enabledBorder: outline(BorderSide(color: colorScheme.outline)),
      focusedBorder: outline(BorderSide(color: colorScheme.primary, width: 2)),
      errorBorder: outline(BorderSide(color: colorScheme.error)),
      focusedErrorBorder: outline(
        BorderSide(color: colorScheme.error, width: 2),
      ),
      disabledBorder: outline(BorderSide(color: colorScheme.outlineVariant)),
    );
  }

  /// Builds the [CardTheme] shared by both light and dark themes.
  ///
  /// - `elevation: 0` — M3-correct: tonal colour differentiates the surface;
  ///   shadow-based elevation is M2 thinking.
  /// - `color: surfaceContainerLow` — one step below the default surface,
  ///   giving cards a subtle recessed feel without a border or shadow.
  /// - [cardBorderRadius] — 16dp (`large`), intentionally softer than inputs.
  static CardThemeData _cardTheme(ColorScheme colorScheme) => CardThemeData(
    elevation: 0,
    color: colorScheme.surfaceContainerLow,
    shape: const RoundedRectangleBorder(borderRadius: cardBorderRadius),
  );
}
