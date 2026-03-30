import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_ui_constants.dart';
import '../../../../core/extensions/error_localization_extension.dart';
import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_loading_state.dart';
import '../../../../core/widgets/app_surface_card.dart';
import '../../domain/entities/expense.dart';
import '../cubit/expense_list_cubit.dart';
import '../cubit/expense_list_state.dart';
import '../widgets/calendar_grid.dart';
import '../widgets/calendar_selected_day_card.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late DateTime _focusedMonth;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    final DateTime now = DateTime.now();
    _focusedMonth = DateTime(now.year, now.month);
    _selectedDate = CalendarGrid.dateOnly(now);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExpenseListCubit, ExpenseListState>(
      builder: (BuildContext context, ExpenseListState state) {
        if (state.status == ExpenseListStatus.loading &&
            state.allExpenses.isEmpty) {
          return const AppLoadingState();
        }

        if (state.status == ExpenseListStatus.failure &&
            state.allExpenses.isEmpty) {
          return AppErrorState(
            message: context.localizeErrorMessage(
              state.errorMessage,
              fallback: context.l10n.failedLoadCalendar,
            ),
            onRetry: () => context.read<ExpenseListCubit>().loadExpenses(),
          );
        }

        final Map<String, _DaySummary> groupedByDay =
            _groupByDay(state.allExpenses);
        final _MonthSummary monthSummary =
            _buildMonthSummary(state.allExpenses, _focusedMonth);
        final String selectedKey = CalendarGrid.dayKey(_selectedDate);
        final _DaySummary? selectedDaySummary = groupedByDay[selectedKey];
        final List<Expense> selectedTransactions =
            List<Expense>.from(selectedDaySummary?.transactions ?? <Expense>[]);

        // Build compact summary map for the grid (amounts only, no transactions)
        final Map<String, CalendarDaySummary> gridSummaries =
            groupedByDay.map((String k, _DaySummary v) => MapEntry(
                  k,
                  CalendarDaySummary(
                    totalExpense: v.totalExpense,
                    totalIncome: v.totalIncome,
                  ),
                ));

        return RefreshIndicator(
          onRefresh: () =>
              context.read<ExpenseListCubit>().loadExpenses(showLoading: false),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.xl - AppSpacing.xxs,
            ),
            children: <Widget>[
              _CalendarMonthHeader(
                focusedMonth: _focusedMonth,
                onPreviousMonth: () => _changeMonth(-1),
                onNextMonth: () => _changeMonth(1),
              ),
              const SizedBox(height: AppSpacing.md),
              _CalendarMonthlySummary(summary: monthSummary),
              const SizedBox(height: AppSpacing.md + AppSpacing.xxs),
              _CalendarWeekdayHeader(),
              const SizedBox(height: AppSpacing.sm),
              CalendarGrid(
                focusedMonth: _focusedMonth,
                selectedDate: _selectedDate,
                daySummaries: gridSummaries,
                onDateSelected: (DateTime date) {
                  setState(() {
                    _selectedDate = date;
                    _focusedMonth = DateTime(date.year, date.month);
                  });
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              CalendarSelectedDayCard(
                selectedDate: _selectedDate,
                transactions: selectedTransactions,
                totalExpense: selectedDaySummary?.totalExpense ?? 0,
                totalIncome: selectedDaySummary?.totalIncome ?? 0,
                categoryById: state.categoryById,
              ),
            ],
          ),
        );
      },
    );
  }

  void _changeMonth(int delta) {
    setState(() {
      _focusedMonth =
          DateTime(_focusedMonth.year, _focusedMonth.month + delta);
      _selectedDate = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    });
  }

  Map<String, _DaySummary> _groupByDay(List<Expense> expenses) {
    final Map<String, _DaySummary> grouped = <String, _DaySummary>{};
    for (final Expense expense in expenses) {
      final String key =
          CalendarGrid.dayKey(CalendarGrid.dateOnly(expense.date));
      final _DaySummary summary =
          grouped.putIfAbsent(key, () => _DaySummary());
      summary.transactions.add(expense);
      if (expense.amount >= 0) {
        summary.totalExpense += expense.amount;
      } else {
        summary.totalIncome += expense.amount.abs();
      }
    }
    return grouped;
  }

  _MonthSummary _buildMonthSummary(
    List<Expense> expenses,
    DateTime month,
  ) {
    double totalExpense = 0;
    double totalIncome = 0;
    for (final Expense expense in expenses) {
      if (expense.date.year != month.year ||
          expense.date.month != month.month) {
        continue;
      }
      if (expense.amount >= 0) {
        totalExpense += expense.amount;
      } else {
        totalIncome += expense.amount.abs();
      }
    }
    return _MonthSummary(totalExpense: totalExpense, totalIncome: totalIncome);
  }

}

// ── Data models ───────────────────────────────────────────────────────────────

class _DaySummary {
  final List<Expense> transactions = <Expense>[];
  double totalExpense = 0;
  double totalIncome = 0;
}

class _MonthSummary {
  const _MonthSummary({
    required this.totalExpense,
    required this.totalIncome,
  });

  final double totalExpense;
  final double totalIncome;

  double get net => totalIncome - totalExpense;
}

// ── Private page widgets ──────────────────────────────────────────────────────

class _CalendarMonthHeader extends StatelessWidget {
  const _CalendarMonthHeader({
    required this.focusedMonth,
    required this.onPreviousMonth,
    required this.onNextMonth,
  });

  final DateTime focusedMonth;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;

  static const double _kNavButtonSize = 36;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                context.l10n.calendarTitle,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                DateFormat(
                  AppDateFormat.monthYear,
                  Localizations.localeOf(context).toString(),
                ).format(focusedMonth),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
        _NavButton(
          size: _kNavButtonSize,
          icon: Icons.chevron_left_rounded,
          onTap: onPreviousMonth,
        ),
        const SizedBox(width: AppSpacing.sm - AppSpacing.xxs),
        _NavButton(
          size: _kNavButtonSize,
          icon: Icons.chevron_right_rounded,
          onTap: onNextMonth,
        ),
      ],
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.size,
    required this.icon,
    required this.onTap,
  });

  final double size;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        onTap: onTap,
        child: SizedBox(width: size, height: size, child: Icon(icon)),
      ),
    );
  }
}

class _CalendarMonthlySummary extends StatelessWidget {
  const _CalendarMonthlySummary({required this.summary});

  final _MonthSummary summary;

  static const double _kDividerHeight = 40;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return AppSurfaceCard(
      padding: const EdgeInsets.all(AppSpacing.lg - AppSpacing.xxs),
      radius: AppRadius.xl,
      outlined: true,
      child: Row(
        children: <Widget>[
          Expanded(
            child: _SummaryItem(
              title: context.l10n.expenseLabel,
              value: CurrencyFormatter.format(summary.totalExpense),
              color: AppTheme.expenseRed,
            ),
          ),
          Container(width: 1, height: _kDividerHeight, color: colorScheme.outline),
          Expanded(
            child: _SummaryItem(
              title: context.l10n.incomeLabel,
              value: CurrencyFormatter.format(summary.totalIncome),
              color: AppTheme.positiveGreen,
            ),
          ),
          Container(width: 1, height: _kDividerHeight, color: colorScheme.outline),
          Expanded(
            child: _SummaryItem(
              title: context.l10n.netLabel,
              value: CurrencyFormatter.format(summary.net),
              color: summary.net >= 0
                  ? AppTheme.positiveGreen
                  : AppTheme.expenseRed,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.title,
    required this.value,
    required this.color,
  });

  final String title;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm + AppSpacing.xxs,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}

class _CalendarWeekdayHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final String locale = Localizations.localeOf(context).toString();
    final DateTime mondayBase = DateTime(2024, 1, 1);
    final List<String> labels = List<String>.generate(
      7,
      (int i) => DateFormat(AppDateFormat.weekdayShort, locale)
          .format(mondayBase.add(Duration(days: i))),
    );

    return Row(
      children: labels
          .map(
            (String label) => Expanded(
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          )
          .toList(growable: false),
    );
  }
}
