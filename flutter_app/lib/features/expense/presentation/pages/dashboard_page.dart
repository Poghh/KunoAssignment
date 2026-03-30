import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_ui_constants.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/extensions/error_localization_extension.dart';
import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_loading_state.dart';
import '../../../../core/widgets/app_section_header.dart';
import '../../../../core/widgets/app_surface_card.dart';
import '../../domain/entities/expense.dart';
import '../cubit/dashboard_cubit.dart';
import '../cubit/dashboard_state.dart';
import '../widgets/category_pie_chart.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/dashboard_total_card.dart';
import '../widgets/expense_card.dart';
import '../widgets/insight_card.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({
    required this.onEditExpense,
    super.key,
  });

  final ValueChanged<Expense> onEditExpense;

  static const int _recentAnimationBaseMs = 260;
  static const int _recentAnimationStaggerMs = 110;

  AppSectionHeader _sectionHeader(
    BuildContext context, {
    required String title,
    required String subtitle,
  }) {
    return AppSectionHeader(
      title: title,
      subtitle: subtitle,
      titleStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
      subtitleStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
      subtitleSpacing: AppSpacing.xs,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (BuildContext context, DashboardState state) {
        if (state.status == DashboardStatus.loading &&
            state.allExpenses.isEmpty) {
          return const AppLoadingState();
        }

        if (state.status == DashboardStatus.failure &&
            state.allExpenses.isEmpty) {
          return AppErrorState(
            message: context.localizeErrorMessage(
              state.errorMessage,
              fallback: context.l10n.failedLoadDashboard,
            ),
            onRetry: () => context.read<DashboardCubit>().loadDashboard(),
          );
        }

        final String locale = Localizations.localeOf(context).toString();
        final String monthLabel = DateFormat(
          AppDateFormat.monthYear,
          locale,
        ).format(state.insights?.monthly.monthDate ?? DateTime.now());

        final DateTime now = DateTime.now();
        final DateTime monthStart = DateTime(now.year, now.month, 1);
        final DateTime monthEnd = DateTime(now.year, now.month + 1, 1);
        final List<Expense> thisMonthExpenses = state.allExpenses
            .where((Expense e) =>
                !e.date.isBefore(monthStart) && e.date.isBefore(monthEnd))
            .toList(growable: false);
        final double monthTotal = thisMonthExpenses
            .where((Expense e) => e.amount >= 0)
            .fold(0.0, (double sum, Expense e) => sum + CurrencyFormatter.effectiveAmount(e));
        final double monthIncome = thisMonthExpenses
            .where((Expense e) => e.amount < 0)
            .fold(0.0, (double sum, Expense e) => sum + CurrencyFormatter.effectiveAmount(e).abs());
        final double dailyAverage = now.day > 0 ? monthTotal / now.day : 0;

        return RefreshIndicator(
          onRefresh: () =>
              context.read<DashboardCubit>().loadDashboard(showLoading: false),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.bottomNavClearance,
            ),
            children: <Widget>[
              DashboardHeader(monthLabel: monthLabel),
              const SizedBox(height: AppSpacing.md + AppSpacing.xxs),
              DashboardTotalCard(
                total: monthTotal,
                income: monthIncome,
                percentage: state.insights?.monthly.percentageChange ?? 0,
              ),
              const SizedBox(height: AppSpacing.lg),
              _sectionHeader(
                context,
                title: context.l10n.categorySplitTitle,
                subtitle: context.l10n.categorySplitSubtitle,
              ),
              const SizedBox(height: AppSpacing.sm + AppSpacing.xxs),
              AppSurfaceCard(
                padding: const EdgeInsets.all(AppSpacing.lg),
                lightShadow: true,
                child: CategoryPieChart(
                  expenses: state.allExpenses,
                  categories: state.categories,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              if (state.insights != null)
                InsightCard(
                  insights: state.insights!,
                  dailyAverage: dailyAverage,
                ),
              const SizedBox(height: AppSpacing.lg),
              _sectionHeader(
                context,
                title: context.l10n.recentTransactionsTitle,
                subtitle: context.l10n.recentTransactionsSubtitle,
              ),
              const SizedBox(height: AppSpacing.sm + AppSpacing.xxs),
              if (state.recentExpenses.isEmpty)
                AppEmptyState(
                  title: context.l10n.noExpensesYetTitle,
                  description: context.l10n.noExpensesYetDescription,
                )
              else
                Column(
                  children: List<Widget>.generate(
                    state.recentExpenses.length,
                    (int index) {
                      final Expense expense = state.recentExpenses[index];
                      return Padding(
                        padding: const EdgeInsets.only(
                            bottom: AppSpacing.sm + AppSpacing.xxs),
                        child: TweenAnimationBuilder<double>(
                          duration: Duration(
                            milliseconds: _recentAnimationBaseMs +
                                (index * _recentAnimationStaggerMs),
                          ),
                          tween: Tween<double>(begin: 0, end: 1),
                          builder: (BuildContext context, double value,
                              Widget? child) {
                            return Transform.translate(
                              offset: Offset(
                                  (1 - value) * AppAnimationOffset.slideEntrance,
                                  0),
                              child: Opacity(opacity: value, child: child),
                            );
                          },
                          child: ExpenseCard(
                            expense: expense,
                            category: state.categoryById(expense.categoryId),
                            onTap: () => onEditExpense(expense),
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
