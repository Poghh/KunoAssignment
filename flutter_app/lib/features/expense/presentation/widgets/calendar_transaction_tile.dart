import 'package:flutter/material.dart';

import '../../../../core/constants/app_ui_constants.dart';
import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/color_parser.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/expense.dart';
import 'category_icon_registry.dart';

class CalendarTransactionTile extends StatelessWidget {
  const CalendarTransactionTile({
    required this.expense,
    this.category,
    super.key,
  });

  final Expense expense;
  final Category? category;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final bool isIncome = expense.amount < 0;
    final bool sameDisplayCurrency =
        expense.currencyCode.toUpperCase() == CurrencyFormatter.currencyCode;
    final double absoluteAmount = sameDisplayCurrency
        ? expense.displayAmount.abs()
        : expense.amount.abs();
    final Color categoryColor =
        parseHexColor(category?.color, fallback: AppTheme.primary);
    final Color amountColor =
        isIncome ? AppTheme.positiveGreen : AppTheme.expenseRed;
    final String amountLabel =
        '${isIncome ? '+' : '-'}${sameDisplayCurrency ? CurrencyFormatter.formatValue(absoluteAmount) : CurrencyFormatter.format(absoluteAmount)}';
    final String subtitle = <String>[
      category?.name ?? context.l10n.categoryFallback,
      if (expense.location != null && expense.location!.isNotEmpty)
        expense.location!,
    ].join(' - ');

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm + AppSpacing.xxs,
        ),
        decoration: BoxDecoration(
          color: colorScheme.surface.withValues(alpha: 0.75),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: colorScheme.outline.withValues(
              alpha:
                  Theme.of(context).brightness == Brightness.dark ? 1 : 0.25,
            ),
          ),
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: AppContainerSize.iconXs,
              height: AppContainerSize.iconXs,
              decoration: BoxDecoration(
                color: categoryColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(
                resolveCategoryIcon(category?.icon),
                size: AppIconSize.sm,
                color: categoryColor,
              ),
            ),
            const SizedBox(width: AppSpacing.sm + AppSpacing.xxs),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    expense.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm + AppSpacing.xxs),
            Text(
              amountLabel,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: amountColor,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
