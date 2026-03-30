import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_ui_constants.dart';
import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_surface_card.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/expense.dart';
import 'calendar_transaction_tile.dart';

/// Card shown below the calendar grid that lists all transactions for the
/// [selectedDate] along with a total expense / income summary.
class CalendarSelectedDayCard extends StatelessWidget {
  const CalendarSelectedDayCard({
    required this.selectedDate,
    required this.transactions,
    required this.totalExpense,
    required this.totalIncome,
    required this.categoryById,
    super.key,
  });

  final DateTime selectedDate;
  final List<Expense> transactions;
  final double totalExpense;
  final double totalIncome;
  final Category? Function(String categoryId) categoryById;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return AppSurfaceCard(
      padding: const EdgeInsets.all(AppSpacing.lg - AppSpacing.xxs),
      radius: AppRadius.xl,
      outlined: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            DateFormat(
              AppDateFormat.fullDate,
              Localizations.localeOf(context).toString(),
            ).format(selectedDate),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            context.l10n.selectedDaySummary(
              CurrencyFormatter.format(totalExpense),
              CurrencyFormatter.format(totalIncome),
            ),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (transactions.isEmpty)
            Text(
              context.l10n.noTransactionsForDay,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            )
          else
            Column(
              children: transactions
                  .map(
                    (Expense expense) => CalendarTransactionTile(
                      expense: expense,
                      category: categoryById(expense.categoryId),
                    ),
                  )
                  .toList(growable: false),
            ),
        ],
      ),
    );
  }
}
