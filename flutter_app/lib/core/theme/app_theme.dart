import 'package:flutter/material.dart';

import '../constants/app_ui_constants.dart';

class AppTheme {
  const AppTheme._();

  // ── Brand colors ──────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF22C55E);
  static const Color background = Color(0xFFF3F5F7);
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkCardBackground = Color(0xFF1E1E1E);
  static const Color darkSurface = Color(0xFF222222);
  static const Color darkInputBackground = Color(0xFF2A2A2A);
  static const Color darkInputBorder = Color(0xFF3A3A3A);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFB0B0B0);
  static const Color darkTextDisabled = Color(0xFF6B6B6B);
  static const Color dividerSubtle = Color(0xFF2C2C2C);

  static const Color expenseRed = Color(0xFFEF4444);
  static const Color positiveGreen = Color(0xFF22C55E);
  static const Color warningOrange = Color(0xFFF59E0B);

  static const Color dashboardGradientDark = Color(0xFF1B5E35);
  static const Color dashboardGradientLight = Color(0xFF4CAF50);

  // Splash screen background gradient
  static const Color splashGradientStart = Color(0xFF16A34A);
  static const Color splashGradientEnd = Color(0xFF4ADE80);

  // Light-theme-specific helper colors
  static const Color _lightOutlineBorder = Color(0xFFBDBDBD); // grey.shade400
  static const Color _lightDisabledBorder = Color(0xFFE0E0E0); // grey.shade300
  static const Color _darkDisabledForeground = Color(0xFF888888);
  static const Color _darkSplash = Color(0x332A2A2A);

  static const List<Color> mutedChartPalette = <Color>[
    Color(0xFF60A5FA),
    Color(0xFF34D399),
    Color(0xFFFBBF24),
    Color(0xFFA78BFA),
  ];

  // ── Shared button style constants ─────────────────────────────────────────
  static const WidgetStatePropertyAll<Size> _filledButtonMinSize =
      WidgetStatePropertyAll<Size>(Size(0, 50));

  static const WidgetStatePropertyAll<EdgeInsetsGeometry> _filledButtonPadding =
      WidgetStatePropertyAll<EdgeInsetsGeometry>(
    EdgeInsets.symmetric(horizontal: 18, vertical: 12),
  );

  static const WidgetStatePropertyAll<Size> _outlinedButtonMinSize =
      WidgetStatePropertyAll<Size>(Size(0, 48));

  static const WidgetStatePropertyAll<EdgeInsetsGeometry>
      _outlinedButtonPadding =
      WidgetStatePropertyAll<EdgeInsetsGeometry>(
    EdgeInsets.symmetric(horizontal: 16, vertical: 11),
  );

  static const WidgetStatePropertyAll<EdgeInsetsGeometry> _textButtonPadding =
      WidgetStatePropertyAll<EdgeInsetsGeometry>(
    EdgeInsets.symmetric(horizontal: 10, vertical: 8),
  );

  static const WidgetStatePropertyAll<double> _zeroElevation =
      WidgetStatePropertyAll<double>(0);

  static const VisualDensity _segmentedDensity =
      VisualDensity(horizontal: -1, vertical: -1);

  // Shape helpers using AppRadius constants
  static WidgetStatePropertyAll<RoundedRectangleBorder> _buttonShape() =>
      WidgetStatePropertyAll<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
      );

  static WidgetStatePropertyAll<RoundedRectangleBorder> _textButtonShape() =>
      WidgetStatePropertyAll<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      );

  static const FloatingActionButtonThemeData _fabTheme =
      FloatingActionButtonThemeData(
    backgroundColor: primary,
    foregroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(AppRadius.xl)),
    ),
    elevation: 1.5,
  );

  // ── Light theme ───────────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
      primary: primary,
      secondary: const Color(0xFF7CCB9F),
      error: expenseRed,
      surface: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: const BorderSide(color: primary, width: 1.4),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          minimumSize: _filledButtonMinSize,
          padding: _filledButtonPadding,
          elevation: _zeroElevation,
          shape: _buttonShape(),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          minimumSize: _outlinedButtonMinSize,
          padding: _outlinedButtonPadding,
          side: WidgetStateProperty.resolveWith<BorderSide>(
            (Set<WidgetState> states) => BorderSide(
              color: states.contains(WidgetState.disabled)
                  ? _lightDisabledBorder
                  : _lightOutlineBorder,
              width: 1,
            ),
          ),
          shape: _buttonShape(),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          shape: _textButtonShape(),
          padding: _textButtonPadding,
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          side: WidgetStateProperty.resolveWith<BorderSide>(
            (Set<WidgetState> states) => BorderSide(
              color: states.contains(WidgetState.selected)
                  ? primary.withValues(alpha: 0.7)
                  : _lightDisabledBorder,
              width: 1,
            ),
          ),
          backgroundColor: WidgetStateProperty.resolveWith<Color?>(
            (Set<WidgetState> states) => states.contains(WidgetState.selected)
                ? primary.withValues(alpha: 0.1)
                : Colors.white,
          ),
          foregroundColor:
              const WidgetStatePropertyAll<Color>(Colors.black87),
          shape: _buttonShape(),
          visualDensity: _segmentedDensity,
        ),
      ),
      floatingActionButtonTheme: _fabTheme,
      dividerColor: dividerSubtle.withValues(alpha: 0.25),
    );
  }

  // ── Dark theme ────────────────────────────────────────────────────────────
  static ThemeData get darkTheme {
    const ColorScheme colorScheme = ColorScheme.dark(
      primary: primary,
      onPrimary: Colors.white,
      secondary: Color(0xFF34D399),
      onSecondary: Color(0xFF062215),
      error: expenseRed,
      onError: Colors.white,
      surface: darkCardBackground,
      onSurface: darkTextPrimary,
      onSurfaceVariant: darkTextSecondary,
      outline: dividerSubtle,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: darkBackground,
      canvasColor: darkBackground,
      dialogTheme: const DialogThemeData(backgroundColor: darkSurface),
      bottomSheetTheme:
          const BottomSheetThemeData(backgroundColor: darkSurface),
      dividerColor: dividerSubtle,
      disabledColor: darkTextDisabled,
      textTheme: ThemeData.dark().textTheme.apply(
            bodyColor: darkTextPrimary,
            displayColor: darkTextPrimary,
          ),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: darkCardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: darkTextSecondary,
        textColor: darkTextPrimary,
      ),
      splashColor: _darkSplash,
      highlightColor: _darkSplash,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkInputBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: const BorderSide(color: darkInputBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: const BorderSide(color: darkInputBorder, width: 1),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide:
              BorderSide(color: darkInputBorder.withValues(alpha: 0.8), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: const BorderSide(color: primary, width: 1.4),
        ),
        labelStyle: const TextStyle(color: darkTextSecondary),
        hintStyle: const TextStyle(color: darkTextSecondary),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          minimumSize: _filledButtonMinSize,
          padding: _filledButtonPadding,
          elevation: _zeroElevation,
          backgroundColor: WidgetStateProperty.resolveWith<Color>(
            (Set<WidgetState> states) => states.contains(WidgetState.disabled)
                ? darkInputBorder
                : primary,
          ),
          foregroundColor: WidgetStateProperty.resolveWith<Color>(
            (Set<WidgetState> states) => states.contains(WidgetState.disabled)
                ? _darkDisabledForeground
                : Colors.white,
          ),
          shape: _buttonShape(),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          minimumSize: _outlinedButtonMinSize,
          padding: _outlinedButtonPadding,
          side: WidgetStateProperty.resolveWith<BorderSide>(
            (Set<WidgetState> states) => BorderSide(
              color: states.contains(WidgetState.disabled)
                  ? darkInputBorder.withValues(alpha: 0.65)
                  : darkInputBorder,
              width: 1,
            ),
          ),
          foregroundColor:
              const WidgetStatePropertyAll<Color>(darkTextPrimary),
          shape: _buttonShape(),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          shape: _textButtonShape(),
          padding: _textButtonPadding,
          foregroundColor:
              const WidgetStatePropertyAll<Color>(darkTextPrimary),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          side: WidgetStateProperty.resolveWith<BorderSide>(
            (Set<WidgetState> states) => BorderSide(
              color: states.contains(WidgetState.selected)
                  ? primary.withValues(alpha: 0.9)
                  : darkInputBorder,
              width: 1,
            ),
          ),
          backgroundColor: WidgetStateProperty.resolveWith<Color?>(
            (Set<WidgetState> states) => states.contains(WidgetState.selected)
                ? primary.withValues(alpha: 0.18)
                : darkInputBackground,
          ),
          foregroundColor:
              const WidgetStatePropertyAll<Color>(darkTextPrimary),
          shape: _buttonShape(),
          visualDensity: _segmentedDensity,
        ),
      ),
      floatingActionButtonTheme: _fabTheme,
    );
  }
}
