import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_ui_constants.dart';
import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_surface_card.dart';
import '../../domain/entities/insight.dart';

class InsightCard extends StatelessWidget {
  const InsightCard({required this.insights, super.key});

  final DashboardInsights insights;

  @override
  Widget build(BuildContext context) {
    final bool isPositive = insights.monthly.percentageChange >= 0;
    final Color trendColor =
        isPositive ? AppTheme.expenseRed : AppTheme.positiveGreen;

    final String trendVerb = isPositive
        ? context.l10n.insightTrendIncreased
        : context.l10n.insightTrendDecreased;
    final String lineOne = context.l10n.insightLineOne(
      insights.category.categoryName ?? context.l10n.insightTopCategoryFallback,
      trendVerb,
      insights.monthly.percentageChange.abs().toStringAsFixed(1),
    );

    final String lineTwo = insights.topDay.weekday == null
        ? context.l10n.insightTopDayEmpty
        : context.l10n.insightTopDayText(
            _localizedWeekday(context, insights.topDay.weekday!));

    return AppSurfaceCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      radius: AppRadius.xl,
      lightShadow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: AppTheme.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: AppSpacing.sm + AppSpacing.xxs),
              Text(
                context.l10n.spendingInsightsTitle,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md + AppSpacing.xxs),
          _InsightRow(
            icon: Icons.trending_up_rounded,
            text: lineOne,
            accent: trendColor,
          ),
          const SizedBox(height: AppSpacing.sm + AppSpacing.xxs),
          _InsightRow(
            icon: Icons.calendar_today_rounded,
            text: lineTwo,
            accent: AppTheme.positiveGreen,
          ),
          const SizedBox(height: AppSpacing.sm + AppSpacing.xxs),
          _InsightRow(
            icon: Icons.show_chart_rounded,
            text: context.l10n.avgDailySpendText(
              CurrencyFormatter.formatValue(insights.dailyAverage.dailyAverage),
            ),
            accent: AppTheme.primary,
          ),
        ],
      ),
    );
  }

  String _localizedWeekday(BuildContext context, String rawWeekday) {
    final String normalized = rawWeekday.trim().toLowerCase();
    const Map<String, int> weekdayOffsets = <String, int>{
      'monday': 0,
      'mon': 0,
      'tuesday': 1,
      'tue': 1,
      'wednesday': 2,
      'wed': 2,
      'thursday': 3,
      'thu': 3,
      'friday': 4,
      'fri': 4,
      'saturday': 5,
      'sat': 5,
      'sunday': 6,
      'sun': 6,
    };

    final int? offset = weekdayOffsets[normalized];
    if (offset == null) {
      return rawWeekday;
    }

    final String locale = Localizations.localeOf(context).toString();
    final DateTime mondayBase = DateTime(2024, 1, 1);
    return DateFormat('EEEE', locale)
        .format(mondayBase.add(Duration(days: offset)));
  }
}

class _InsightRow extends StatelessWidget {
  const _InsightRow({
    required this.icon,
    required this.text,
    required this.accent,
  });

  final IconData icon;
  final String text;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(icon, size: 18, color: accent),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ],
    );
  }
}
