import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_ui_constants.dart';
import '../../../../core/extensions/error_localization_extension.dart';
import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/color_parser.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_loading_state.dart';
import '../../../../core/widgets/app_surface_card.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/expense.dart';
import '../cubit/expense_list_cubit.dart';
import '../cubit/expense_list_state.dart';
import '../widgets/category_icon_registry.dart';

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
    _selectedDate = _dateOnly(now);
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
        final List<Expense> selectedDayTransactions = List<Expense>.from(
          groupedByDay[_dayKey(_selectedDate)]?.transactions ?? <Expense>[],
        );

        return RefreshIndicator(
          onRefresh: () =>
              context.read<ExpenseListCubit>().loadExpenses(showLoading: false),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg - AppSpacing.xs,
              AppSpacing.lg,
              AppSpacing.xl - AppSpacing.xxs,
            ),
            children: <Widget>[
              _buildMonthHeader(context),
              const SizedBox(height: AppSpacing.md),
              _buildMonthlySummary(context, monthSummary),
              const SizedBox(height: AppSpacing.md + AppSpacing.xxs),
              _buildWeekdayHeader(context),
              const SizedBox(height: AppSpacing.sm),
              _buildCalendarGrid(groupedByDay),
              const SizedBox(height: AppSpacing.lg),
              _buildSelectedDayCard(
                context,
                selectedDayTransactions: selectedDayTransactions,
                state: state,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMonthHeader(BuildContext context) {
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
                  'MMMM yyyy',
                  Localizations.localeOf(context).toString(),
                ).format(_focusedMonth),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
        _MonthNavButton(
          icon: Icons.chevron_left_rounded,
          onTap: () => _changeMonth(-1),
        ),
        const SizedBox(width: AppSpacing.sm - AppSpacing.xxs),
        _MonthNavButton(
          icon: Icons.chevron_right_rounded,
          onTap: () => _changeMonth(1),
        ),
      ],
    );
  }

  Widget _buildMonthlySummary(BuildContext context, _MonthSummary summary) {
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
          Container(
            width: 1,
            height: _CalendarMetrics.summaryDividerHeight,
            color: colorScheme.outline,
          ),
          Expanded(
            child: _SummaryItem(
              title: context.l10n.incomeLabel,
              value: CurrencyFormatter.format(summary.totalIncome),
              color: AppTheme.positiveGreen,
            ),
          ),
          Container(
            width: 1,
            height: _CalendarMetrics.summaryDividerHeight,
            color: colorScheme.outline,
          ),
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

  Widget _buildWeekdayHeader(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: _weekdayLabels(context)
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

  Widget _buildCalendarGrid(Map<String, _DaySummary> groupedByDay) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final List<DateTime> days = _buildCalendarDays(_focusedMonth);
    final DateTime today = _dateOnly(DateTime.now());

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: days.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        crossAxisSpacing: AppSpacing.sm - AppSpacing.xxs,
        mainAxisSpacing: AppSpacing.sm - AppSpacing.xxs,
        childAspectRatio: 0.82,
      ),
      itemBuilder: (BuildContext context, int index) {
        final DateTime date = days[index];
        final bool isCurrentMonth = date.year == _focusedMonth.year &&
            date.month == _focusedMonth.month;
        final bool isSelected = _isSameDate(date, _selectedDate);
        final bool isToday = _isSameDate(date, today);
        final _DaySummary? summary = groupedByDay[_dayKey(date)];

        final Color borderColor = isSelected
            ? AppTheme.primary
            : isToday
                ? AppTheme.primary.withValues(alpha: 0.45)
                : colorScheme.outline;

        return InkWell(
          borderRadius: BorderRadius.circular(AppRadius.md),
          onTap: () {
            setState(() {
              _selectedDate = date;
              _focusedMonth = DateTime(date.year, date.month);
            });
          },
          child: Container(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.sm - AppSpacing.xxs - 1,
              AppSpacing.sm - AppSpacing.xxs - 1,
              AppSpacing.sm - AppSpacing.xxs - 1,
              AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.primary.withValues(alpha: 0.12)
                  : isCurrentMonth
                      ? colorScheme.surface
                      : colorScheme.surface.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: _CalendarMetrics.dayBadgeSize,
                  height: _CalendarMetrics.dayBadgeSize,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isToday ? AppTheme.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppSpacing.sm),
                  ),
                  child: Text(
                    '${date.day}',
                    style: TextStyle(
                      fontSize: _CalendarMetrics.dayNumberFontSize,
                      fontWeight: FontWeight.w700,
                      color: isToday
                          ? colorScheme.onPrimary
                          : isCurrentMonth
                              ? colorScheme.onSurface
                              : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const Spacer(),
                if (summary != null && summary.totalExpense > 0)
                  Text(
                    '-${CurrencyFormatter.formatCompact(summary.totalExpense)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: _CalendarMetrics.dayAmountFontSize,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.expenseRed,
                    ),
                  ),
                if (summary != null && summary.totalIncome > 0)
                  Text(
                    '+${CurrencyFormatter.formatCompact(summary.totalIncome)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: _CalendarMetrics.dayAmountFontSize,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.positiveGreen,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSelectedDayCard(
    BuildContext context, {
    required List<Expense> selectedDayTransactions,
    required ExpenseListState state,
  }) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    final _DaySummary selectedSummary =
        _groupByDay(selectedDayTransactions)[_dayKey(_selectedDate)] ??
            _DaySummary();

    return AppSurfaceCard(
      padding: const EdgeInsets.all(AppSpacing.lg - AppSpacing.xxs),
      radius: AppRadius.xl,
      outlined: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            DateFormat(
              'EEEE, dd MMM yyyy',
              Localizations.localeOf(context).toString(),
            ).format(_selectedDate),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            context.l10n.selectedDaySummary(
              CurrencyFormatter.format(selectedSummary.totalExpense),
              CurrencyFormatter.format(selectedSummary.totalIncome),
            ),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (selectedDayTransactions.isEmpty)
            Text(
              context.l10n.noTransactionsForDay,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            )
          else
            Column(
              children: selectedDayTransactions
                  .map(
                    (Expense expense) => _CalendarTransactionTile(
                      expense: expense,
                      category: state.categoryById(expense.categoryId),
                    ),
                  )
                  .toList(growable: false),
            ),
        ],
      ),
    );
  }

  void _changeMonth(int delta) {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + delta);
      _selectedDate = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    });
  }

  List<DateTime> _buildCalendarDays(DateTime month) {
    final DateTime monthStart = DateTime(month.year, month.month, 1);
    final int leadingDays = monthStart.weekday - 1;
    final DateTime firstGridDay =
        monthStart.subtract(Duration(days: leadingDays));

    return List<DateTime>.generate(
      42,
      (int index) => firstGridDay.add(Duration(days: index)),
    );
  }

  Map<String, _DaySummary> _groupByDay(List<Expense> expenses) {
    final Map<String, _DaySummary> grouped = <String, _DaySummary>{};

    for (final Expense expense in expenses) {
      final DateTime day = _dateOnly(expense.date);
      final String key = _dayKey(day);
      final _DaySummary summary = grouped.putIfAbsent(key, () => _DaySummary());

      summary.transactions.add(expense);
      if (expense.amount >= 0) {
        summary.totalExpense += expense.amount;
      } else {
        summary.totalIncome += expense.amount.abs();
      }
    }

    return grouped;
  }

  _MonthSummary _buildMonthSummary(List<Expense> expenses, DateTime month) {
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

    return _MonthSummary(
      totalExpense: totalExpense,
      totalIncome: totalIncome,
    );
  }

  DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  String _dayKey(DateTime date) {
    final String month = date.month.toString().padLeft(2, '0');
    final String day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  bool _isSameDate(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  List<String> _weekdayLabels(BuildContext context) {
    final String locale = Localizations.localeOf(context).toString();
    final DateTime mondayBase = DateTime(2024, 1, 1);
    return List<String>.generate(
      7,
      (int index) => DateFormat('EEE', locale)
          .format(mondayBase.add(Duration(days: index))),
    );
  }
}

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

class _MonthNavButton extends StatelessWidget {
  const _MonthNavButton({
    required this.icon,
    required this.onTap,
  });

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
        child: SizedBox(
          width: _CalendarMetrics.monthNavButtonSize,
          height: _CalendarMetrics.monthNavButtonSize,
          child: Icon(icon),
        ),
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
          horizontal: AppSpacing.sm + AppSpacing.xxs),
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

class _CalendarTransactionTile extends StatelessWidget {
  const _CalendarTransactionTile({
    required this.expense,
    this.category,
  });

  final Expense expense;
  final Category? category;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final bool isIncome = expense.amount < 0;
    final double absoluteAmount = expense.amount.abs();
    final Color amountColor =
        isIncome ? AppTheme.positiveGreen : AppTheme.expenseRed;
    final String amountLabel =
        '${isIncome ? '+' : '-'}${CurrencyFormatter.format(absoluteAmount)}';

    final String subtitle = [
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
              alpha: Theme.of(context).brightness == Brightness.dark ? 1 : 0.25,
            ),
          ),
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: _CalendarMetrics.transactionIconContainerSize,
              height: _CalendarMetrics.transactionIconContainerSize,
              decoration: BoxDecoration(
                color:
                    parseHexColor(category?.color, fallback: AppTheme.primary)
                        .withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(
                resolveCategoryIcon(category?.icon),
                size: _CalendarMetrics.transactionIconSize,
                color:
                    parseHexColor(category?.color, fallback: AppTheme.primary),
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

class _CalendarMetrics {
  const _CalendarMetrics._();

  static const double summaryDividerHeight = 40;
  static const double dayBadgeSize = 21;
  static const double dayNumberFontSize = 12;
  static const double dayAmountFontSize = 9.5;
  static const double monthNavButtonSize = 36;
  static const double transactionIconContainerSize = 32;
  static const double transactionIconSize = 18;
}
