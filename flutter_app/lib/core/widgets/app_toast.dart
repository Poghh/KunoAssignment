import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../theme/app_theme.dart';

enum AppToastType {
  success,
  error,
  info,
}

class AppToast {
  const AppToast._();

  static Future<void> success(String message) {
    return _show(message, type: AppToastType.success);
  }

  static Future<void> error(String message) {
    return _show(message, type: AppToastType.error);
  }

  static Future<void> info(String message) {
    return _show(message, type: AppToastType.info);
  }

  static Future<void> _show(
    String message, {
    required AppToastType type,
  }) async {
    if (message.trim().isEmpty) {
      return;
    }

    final _ToastColors colors = _resolveColors(type);

    await Fluttertoast.cancel();
    await Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: colors.background,
      textColor: colors.foreground,
      fontSize: 14,
      webBgColor:
          'linear-gradient(to right, ${_toHex(colors.background)}, ${_toHex(colors.background)})',
      webPosition: 'center',
    );
  }

  static _ToastColors _resolveColors(AppToastType type) {
    switch (type) {
      case AppToastType.success:
        return const _ToastColors(
          background: AppTheme.positiveGreen,
          foreground: Colors.white,
        );
      case AppToastType.error:
        return const _ToastColors(
          background: AppTheme.expenseRed,
          foreground: Colors.white,
        );
      case AppToastType.info:
        return const _ToastColors(
          background: AppTheme.dividerSubtle,
          foreground: Colors.white,
        );
    }
  }

  static String _toHex(Color color) {
    return '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}';
  }
}

class _ToastColors {
  const _ToastColors({
    required this.background,
    required this.foreground,
  });

  final Color background;
  final Color foreground;
}
