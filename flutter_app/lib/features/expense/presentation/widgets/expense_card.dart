import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_ui_constants.dart';
import '../../../../core/extensions/category_localization_extension.dart';
import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/color_parser.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/expense.dart';
import 'category_icon_registry.dart';

class ExpenseCard extends StatelessWidget {
  const ExpenseCard({
    required this.expense,
    this.category,
    this.onTap,
    super.key,
  });

  final Expense expense;
  final Category? category;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final String locale = Localizations.localeOf(context).toString();
    final bool isIncome = expense.amount < 0;
    final double absoluteAmount = expense.displayAmount.abs();
    final Color categoryColor =
        parseHexColor(category?.color, fallback: AppTheme.primary);
    final String subtitle = [
      DateFormat('EEE, dd MMM', locale).format(expense.date),
      if (expense.location != null && expense.location!.isNotEmpty)
        expense.location!,
    ].join(' - ');

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg - AppSpacing.xxs),
          child: Row(
            children: <Widget>[
              Container(
                width: _ExpenseCardMetrics.iconContainerSize,
                height: _ExpenseCardMetrics.iconContainerSize,
                decoration: BoxDecoration(
                  color: categoryColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  resolveCategoryIcon(category?.icon),
                  color: categoryColor,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      expense.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(
                    '${isIncome ? '+' : '-'}${CurrencyFormatter.formatValue(absoluteAmount)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: isIncome
                              ? AppTheme.positiveGreen
                              : Theme.of(context).colorScheme.error,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.xxs + 1),
                  Text(
                    context.l10n.localizeCategory(category?.name),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExpenseCardMetrics {
  const _ExpenseCardMetrics._();

  static const double iconContainerSize = 44;
}
