import 'package:flutter/material.dart';

import '../../../../core/constants/app_ui_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_formatter.dart';

/// Summary of expenses/income for a single calendar day.
class CalendarDaySummary {
  const CalendarDaySummary({this.totalExpense = 0, this.totalIncome = 0});

  final double totalExpense;
  final double totalIncome;
}

/// 6-week calendar grid for [focusedMonth].
///
/// Calls [onDateSelected] when the user taps a day. Displays compact
/// expense/income amounts from [daySummaries] keyed by [CalendarGrid.dayKey].
class CalendarGrid extends StatelessWidget {
  const CalendarGrid({
    required this.focusedMonth,
    required this.selectedDate,
    required this.onDateSelected,
    required this.daySummaries,
    super.key,
  });

  final DateTime focusedMonth;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final Map<String, CalendarDaySummary> daySummaries;

  // ── Public utilities (shared with CalendarPage) ────────────────────────────

  static String dayKey(DateTime date) {
    final String m = date.month.toString().padLeft(2, '0');
    final String d = date.day.toString().padLeft(2, '0');
    return '${date.year}-$m-$d';
  }

  static DateTime dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  static bool isSameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// Generates 42 dates (6 rows × 7 cols) starting from the Monday before
  /// [month]'s first day.
  static List<DateTime> buildMonthDays(DateTime month) {
    final DateTime first = DateTime(month.year, month.month, 1);
    final DateTime gridStart = first.subtract(Duration(days: first.weekday - 1));
    return List<DateTime>.generate(
      _kGridCellCount,
      (int i) => gridStart.add(Duration(days: i)),
    );
  }

  static const int _kGridCellCount = 42;
  static const double _kCellSpacing = AppSpacing.sm - AppSpacing.xxs;
  static const double _kCellAspectRatio = 0.82;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final List<DateTime> days = buildMonthDays(focusedMonth);
    final DateTime today = dateOnly(DateTime.now());

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: days.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        crossAxisSpacing: _kCellSpacing,
        mainAxisSpacing: _kCellSpacing,
        childAspectRatio: _kCellAspectRatio,
      ),
      itemBuilder: (BuildContext context, int index) {
        final DateTime date = days[index];
        final bool isCurrentMonth =
            date.year == focusedMonth.year && date.month == focusedMonth.month;
        final bool isSelected = isSameDate(date, selectedDate);
        final bool isToday = isSameDate(date, today);
        final CalendarDaySummary? summary = daySummaries[dayKey(date)];

        return _CalendarDayCell(
          date: date,
          isCurrentMonth: isCurrentMonth,
          isSelected: isSelected,
          isToday: isToday,
          summary: summary,
          colorScheme: colorScheme,
          onTap: () => onDateSelected(date),
        );
      },
    );
  }
}

// ── Day cell ──────────────────────────────────────────────────────────────────

class _CalendarDayCell extends StatelessWidget {
  const _CalendarDayCell({
    required this.date,
    required this.isCurrentMonth,
    required this.isSelected,
    required this.isToday,
    required this.summary,
    required this.colorScheme,
    required this.onTap,
  });

  final DateTime date;
  final bool isCurrentMonth;
  final bool isSelected;
  final bool isToday;
  final CalendarDaySummary? summary;
  final ColorScheme colorScheme;
  final VoidCallback onTap;

  // Cell inner padding — 1 px tighter than sm-xxs on all sides except bottom
  static const double _kInnerPadding = AppSpacing.sm - AppSpacing.xxs - 1;

  @override
  Widget build(BuildContext context) {
    final Color borderColor = isSelected
        ? AppTheme.primary
        : isToday
            ? AppTheme.primary.withValues(alpha: 0.45)
            : colorScheme.outline;

    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.md),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          _kInnerPadding,
          _kInnerPadding,
          _kInnerPadding,
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
            _DayBadge(
              day: date.day,
              isToday: isToday,
              isCurrentMonth: isCurrentMonth,
              colorScheme: colorScheme,
            ),
            const Spacer(),
            if (summary != null && summary!.totalExpense > 0)
              _DayAmount(
                prefix: '-',
                amount: summary!.totalExpense,
                color: AppTheme.expenseRed,
              ),
            if (summary != null && summary!.totalIncome > 0)
              _DayAmount(
                prefix: '+',
                amount: summary!.totalIncome,
                color: AppTheme.positiveGreen,
              ),
          ],
        ),
      ),
    );
  }
}

class _DayBadge extends StatelessWidget {
  const _DayBadge({
    required this.day,
    required this.isToday,
    required this.isCurrentMonth,
    required this.colorScheme,
  });

  final int day;
  final bool isToday;
  final bool isCurrentMonth;
  final ColorScheme colorScheme;

  static const double _kSize = 21;
  static const double _kFontSize = 12;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _kSize,
      height: _kSize,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isToday ? AppTheme.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(AppSpacing.sm),
      ),
      child: Text(
        '$day',
        style: TextStyle(
          fontSize: _kFontSize,
          fontWeight: FontWeight.w700,
          color: isToday
              ? colorScheme.onPrimary
              : isCurrentMonth
                  ? colorScheme.onSurface
                  : colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _DayAmount extends StatelessWidget {
  const _DayAmount({
    required this.prefix,
    required this.amount,
    required this.color,
  });

  final String prefix;
  final double amount;
  final Color color;

  static const double _kFontSize = 9.5;

  @override
  Widget build(BuildContext context) {
    return Text(
      '$prefix${CurrencyFormatter.formatCompact(amount)}',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: _kFontSize,
        fontWeight: FontWeight.w700,
        color: color,
      ),
    );
  }
}
