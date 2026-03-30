import 'package:flutter/material.dart';

import '../../../../core/constants/app_ui_constants.dart';
import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_formatter.dart';

class DashboardTotalCard extends StatelessWidget {
  const DashboardTotalCard({
    required this.total,
    required this.income,
    required this.percentage,
    super.key,
  });

  final double total;
  final double income;
  final double percentage;

  // These values are design-specific and intentionally not in AppSpacing/AppRadius.
  static const double _cardPadding = 18;
  static const double _shadowBlur = 18;
  static const double _shadowOffsetY = AppSpacing.md; // 12
  static const double _badgeRadius = AppSpacing.xl;   // 20
  static const double _badgeIconSize = 14;
  static const double _maxBadgeWidth = 220;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final bool increased = percentage >= 0;
    final Color badgeColor =
        increased ? AppTheme.expenseRed : AppTheme.positiveGreen;

    return Container(
      padding: const EdgeInsets.all(_cardPadding),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? <Color>[
                  AppTheme.dashboardGradientDark,
                  AppTheme.primary.withValues(alpha: 0.92),
                ]
              : <Color>[
                  AppTheme.primary,
                  AppTheme.dashboardGradientLight,
                ],
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: isDark ? 0.12 : 0.25),
            blurRadius: _shadowBlur,
            offset: const Offset(0, _shadowOffsetY),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            context.l10n.totalThisMonth,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            CurrencyFormatter.format(total),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: AppSpacing.sm + AppSpacing.xxs),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: <Widget>[
              _DashboardBadge(
                isDark: isDark,
                badgeRadius: _badgeRadius,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      increased
                          ? Icons.arrow_upward_rounded
                          : Icons.arrow_downward_rounded,
                      size: _badgeIconSize,
                      color: badgeColor,
                    ),
                    const SizedBox(width: AppSpacing.sm - AppSpacing.xxs),
                    Text(
                      context.l10n.summaryVsLastMonth(
                        percentage.abs().toStringAsFixed(1),
                      ),
                      style: TextStyle(
                        color: badgeColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: _maxBadgeWidth),
                child: _DashboardBadge(
                  isDark: isDark,
                  badgeRadius: _badgeRadius,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const Icon(
                        Icons.arrow_downward_rounded,
                        size: _badgeIconSize,
                        color: AppTheme.positiveGreen,
                      ),
                      const SizedBox(width: AppSpacing.sm - AppSpacing.xxs),
                      Flexible(
                        child: Text(
                          '${context.l10n.incomeLabel}: ${CurrencyFormatter.format(income)}',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: const TextStyle(
                            color: AppTheme.positiveGreen,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DashboardBadge extends StatelessWidget {
  const _DashboardBadge({
    required this.isDark,
    required this.badgeRadius,
    required this.child,
  });

  final bool isDark;
  final double badgeRadius;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm + AppSpacing.xxs,
        vertical: AppSpacing.sm - AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? colorScheme.surface.withValues(alpha: 0.95)
            : Colors.white,
        borderRadius: BorderRadius.circular(badgeRadius),
      ),
      child: child,
    );
  }
}
