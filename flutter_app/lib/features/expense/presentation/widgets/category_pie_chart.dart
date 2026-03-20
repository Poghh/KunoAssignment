import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_ui_constants.dart';
import '../../../../core/extensions/category_localization_extension.dart';
import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/expense.dart';
import 'category_icon_registry.dart';

class CategoryPieChart extends StatefulWidget {
  const CategoryPieChart({
    required this.expenses,
    required this.categories,
    super.key,
  });

  final List<Expense> expenses;
  final List<Category> categories;

  @override
  State<CategoryPieChart> createState() => _CategoryPieChartState();
}

class _CategoryPieChartState extends State<CategoryPieChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final DateTime now = DateTime.now();
    final List<Expense> monthExpenses =
        widget.expenses.where((Expense expense) {
      return expense.date.year == now.year &&
          expense.date.month == now.month &&
          expense.amount > 0;
    }).toList(growable: false);

    if (monthExpenses.isEmpty) {
      return _buildEmpty(context);
    }

    final Map<String, double> grouped = <String, double>{};
    for (final Expense expense in monthExpenses) {
      grouped[expense.categoryId] =
          (grouped[expense.categoryId] ?? 0) + expense.displayAmount;
    }

    final List<_SliceData> slices =
        grouped.entries.map((MapEntry<String, double> entry) {
      final Category? category = _findCategory(entry.key);
      return _SliceData(
        categoryId: entry.key,
        categoryName: category != null
            ? context.l10n.localizeCategory(category.name)
            : context.l10n.otherCategory,
        iconKey: category?.icon,
        amount: entry.value,
        color: _paletteColor(entry.key.hashCode),
      );
    }).toList()
          ..sort((first, second) => second.amount.compareTo(first.amount));

    final double total = slices.fold<double>(
        0, (double sum, _SliceData item) => sum + item.amount);

    return Column(
      children: <Widget>[
        SizedBox(
          height: _PieChartMetrics.chartHeight,
          child: PieChart(
            PieChartData(
              centerSpaceRadius: _PieChartMetrics.centerSpaceRadius,
              sectionsSpace: _PieChartMetrics.sectionSpace,
              pieTouchData: PieTouchData(
                touchCallback:
                    (FlTouchEvent event, PieTouchResponse? response) {
                  setState(() {
                    touchedIndex =
                        response?.touchedSection?.touchedSectionIndex ?? -1;
                  });
                },
              ),
              sections: List<PieChartSectionData>.generate(
                slices.length,
                (int index) {
                  final _SliceData slice = slices[index];
                  final bool isTouched = index == touchedIndex;

                  return PieChartSectionData(
                    color: slice.color,
                    value: slice.amount,
                    radius: isTouched
                        ? _PieChartMetrics.touchedRadius
                        : _PieChartMetrics.defaultRadius,
                    title: '${(slice.amount / total * 100).round()}%',
                    titleStyle: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      fontSize: _PieChartMetrics.labelSize,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm + AppSpacing.xxs),
        Column(
          children: slices.take(4).map((slice) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                children: <Widget>[
                  Container(
                    width: _PieChartMetrics.dotSize,
                    height: _PieChartMetrics.dotSize,
                    decoration: BoxDecoration(
                      color: slice.color,
                      borderRadius: BorderRadius.circular(_PieChartMetrics.dotRadius),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Row(
                      children: <Widget>[
                        Icon(
                          resolveCategoryIcon(slice.iconKey),
                          size: _PieChartMetrics.categoryIconSize,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: AppSpacing.sm - AppSpacing.xxs),
                        Expanded(
                          child: Text(
                            slice.categoryName,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    CurrencyFormatter.formatValue(slice.amount),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildEmpty(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: _PieChartMetrics.chartHeight,
      child: Center(
        child: Text(
          context.l10n.noCategorySpendingYetThisMonth,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
        ),
      ),
    );
  }

  Category? _findCategory(String categoryId) {
    for (final Category category in widget.categories) {
      if (category.id == categoryId) {
        return category;
      }
    }

    return null;
  }

  Color _paletteColor(int seed) {
    return AppTheme
        .mutedChartPalette[seed.abs() % AppTheme.mutedChartPalette.length];
  }
}

class _PieChartMetrics {
  const _PieChartMetrics._();

  static const double chartHeight = 220;
  static const double centerSpaceRadius = 38;
  static const double sectionSpace = 3;
  static const double touchedRadius = 78;
  static const double defaultRadius = 68;
  static const double labelSize = 12;
  static const double dotSize = 10;
  static const double dotRadius = 50;
  static const double categoryIconSize = 16;
}

class _SliceData {
  const _SliceData({
    required this.categoryId,
    required this.categoryName,
    required this.iconKey,
    required this.amount,
    required this.color,
  });

  final String categoryId;
  final String categoryName;
  final String? iconKey;
  final double amount;
  final Color color;
}
