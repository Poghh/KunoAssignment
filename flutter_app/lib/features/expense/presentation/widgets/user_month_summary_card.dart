import 'package:flutter/material.dart';

import '../../../../core/constants/app_ui_constants.dart';
import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_surface_card.dart';

class UserMonthSummaryCard extends StatelessWidget {
  const UserMonthSummaryCard({
    required this.monthLabel,
    required this.totalThisMonth,
    required this.dailyAverage,
    super.key,
  });

  final String monthLabel;
  final double totalThisMonth;
  final double dailyAverage;

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      radius: AppRadius.xxl,
      outlined: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            monthLabel,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: AppSpacing.sm + AppSpacing.xxs),
          Row(
            children: <Widget>[
              Expanded(
                child: _SummaryItem(
                  label: context.l10n.summaryTotalThisMonth,
                  value: CurrencyFormatter.formatValue(totalThisMonth),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _SummaryItem(
                  label: context.l10n.summaryAvgDaily,
                  value: CurrencyFormatter.formatValue(dailyAverage),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return AppSurfaceCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      radius: AppRadius.md,
      outlined: false,
      color: colorScheme.primary.withValues(alpha: 0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}
