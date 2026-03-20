import 'package:flutter/material.dart';

class AppTheme {
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

  static const List<Color> mutedChartPalette = <Color>[
    Color(0xFF60A5FA),
    Color(0xFF34D399),
    Color(0xFFFBBF24),
    Color(0xFFA78BFA),
  ];

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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primary, width: 1.4),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll<Size>(Size(0, 50)),
          padding: const WidgetStatePropertyAll<EdgeInsetsGeometry>(
            EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          ),
          elevation: const WidgetStatePropertyAll<double>(0),
          shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll<Size>(Size(0, 48)),
          padding: const WidgetStatePropertyAll<EdgeInsetsGeometry>(
            EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          ),
          side: WidgetStateProperty.resolveWith<BorderSide>(
            (Set<WidgetState> states) {
              final bool isDisabled = states.contains(WidgetState.disabled);
              return BorderSide(
                color: isDisabled ? Colors.grey.shade300 : Colors.grey.shade400,
                width: 1,
              );
            },
          ),
          shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          padding: const WidgetStatePropertyAll<EdgeInsetsGeometry>(
            EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          ),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          side: WidgetStateProperty.resolveWith<BorderSide>(
            (Set<WidgetState> states) {
              final bool isSelected = states.contains(WidgetState.selected);
              return BorderSide(
                color: isSelected
                    ? primary.withValues(alpha: 0.7)
                    : Colors.grey.shade300,
                width: 1,
              );
            },
          ),
          backgroundColor: WidgetStateProperty.resolveWith<Color?>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.selected)) {
                return primary.withValues(alpha: 0.1);
              }
              return Colors.white;
            },
          ),
          foregroundColor: const WidgetStatePropertyAll<Color>(Colors.black87),
          shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          visualDensity: const VisualDensity(horizontal: -1, vertical: -1),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 1.5,
      ),
      dividerColor: dividerSubtle.withValues(alpha: 0.25),
    );
  }

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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: darkTextSecondary,
        textColor: darkTextPrimary,
      ),
      splashColor: const Color(0x332A2A2A),
      highlightColor: const Color(0x332A2A2A),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkInputBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: darkInputBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: darkInputBorder, width: 1),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
              color: darkInputBorder.withValues(alpha: 0.8), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primary, width: 1.4),
        ),
        labelStyle: const TextStyle(color: darkTextSecondary),
        hintStyle: const TextStyle(color: darkTextSecondary),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll<Size>(Size(0, 50)),
          padding: const WidgetStatePropertyAll<EdgeInsetsGeometry>(
            EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          ),
          elevation: const WidgetStatePropertyAll<double>(0),
          backgroundColor: WidgetStateProperty.resolveWith<Color>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.disabled)) {
                return darkInputBorder;
              }
              return primary;
            },
          ),
          foregroundColor: WidgetStateProperty.resolveWith<Color>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.disabled)) {
                return const Color(0xFF888888);
              }
              return Colors.white;
            },
          ),
          shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll<Size>(Size(0, 48)),
          padding: const WidgetStatePropertyAll<EdgeInsetsGeometry>(
            EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          ),
          side: WidgetStateProperty.resolveWith<BorderSide>(
            (Set<WidgetState> states) {
              final bool isDisabled = states.contains(WidgetState.disabled);
              return BorderSide(
                color: isDisabled
                    ? darkInputBorder.withValues(alpha: 0.65)
                    : darkInputBorder,
                width: 1,
              );
            },
          ),
          foregroundColor: const WidgetStatePropertyAll<Color>(darkTextPrimary),
          shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          padding: const WidgetStatePropertyAll<EdgeInsetsGeometry>(
            EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          ),
          foregroundColor: const WidgetStatePropertyAll<Color>(darkTextPrimary),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          side: WidgetStateProperty.resolveWith<BorderSide>(
            (Set<WidgetState> states) {
              final bool isSelected = states.contains(WidgetState.selected);
              return BorderSide(
                color: isSelected
                    ? primary.withValues(alpha: 0.9)
                    : darkInputBorder,
                width: 1,
              );
            },
          ),
          backgroundColor: WidgetStateProperty.resolveWith<Color?>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.selected)) {
                return primary.withValues(alpha: 0.18);
              }
              return darkInputBackground;
            },
          ),
          foregroundColor: const WidgetStatePropertyAll<Color>(darkTextPrimary),
          shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          visualDensity: const VisualDensity(horizontal: -1, vertical: -1),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 1.5,
      ),
    );
  }
}
