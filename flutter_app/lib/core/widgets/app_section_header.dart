import 'package:flutter/material.dart';

import '../constants/app_ui_constants.dart';

class AppSectionHeader extends StatelessWidget {
  const AppSectionHeader({
    required this.title,
    required this.subtitle,
    this.titleStyle,
    this.subtitleStyle,
    this.subtitleSpacing = AppSpacing.xxs,
    super.key,
  });

  final String title;
  final String subtitle;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;
  final double subtitleSpacing;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: titleStyle ??
              theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        SizedBox(height: subtitleSpacing),
        Text(
          subtitle,
          style: subtitleStyle ??
              theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}
