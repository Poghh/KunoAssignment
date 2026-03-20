import 'package:flutter/material.dart';

import '../constants/app_ui_constants.dart';
import '../theme/app_theme.dart';

class AppSurfaceCard extends StatelessWidget {
  const AppSurfaceCard({
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.radius = AppRadius.xl,
    this.outlined = true,
    this.lightShadow = false,
    this.color,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final bool outlined;
  final bool lightShadow;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final bool isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? colorScheme.surface,
        borderRadius: BorderRadius.circular(radius),
        border: outlined
            ? Border.all(
                color: isDark
                    ? AppTheme.dividerSubtle
                    : AppTheme.dividerSubtle.withValues(alpha: 0.2),
              )
            : null,
        boxShadow: <BoxShadow>[
          if (lightShadow && !isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
        ],
      ),
      child: child,
    );
  }
}
