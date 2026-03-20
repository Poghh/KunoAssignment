import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_ui_constants.dart';
import '../../../../core/cubit/auth_cubit.dart';
import '../../../../core/extensions/error_localization_extension.dart';
import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_loading_state.dart';
import '../../../../core/widgets/app_section_header.dart';
import '../../../../core/widgets/app_surface_card.dart';
import '../../domain/entities/expense.dart';
import '../cubit/dashboard_cubit.dart';
import '../cubit/dashboard_state.dart';
import '../widgets/category_pie_chart.dart';
import '../widgets/expense_card.dart';
import '../widgets/insight_card.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({
    required this.onEditExpense,
    super.key,
  });

  final ValueChanged<Expense> onEditExpense;

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

        final double monthTotal = state.insights?.monthly.totalThisMonth ?? 0;
        final String monthLabel = state.insights?.monthly.month ??
            DateFormat(
              'MMMM yyyy',
              Localizations.localeOf(context).toString(),
            ).format(DateTime.now());

        final DateTime now = DateTime.now();
        final DateTime monthStart = DateTime(now.year, now.month, 1);
        final DateTime monthEnd = DateTime(now.year, now.month + 1, 1);
        final double monthIncome = state.allExpenses
            .where((Expense e) =>
                e.amount < 0 &&
                !e.date.isBefore(monthStart) &&
                e.date.isBefore(monthEnd))
            .fold(0.0, (double sum, Expense e) => sum + e.displayAmount.abs());

        return RefreshIndicator(
          onRefresh: () =>
              context.read<DashboardCubit>().loadDashboard(showLoading: false),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg - AppSpacing.xs,
              AppSpacing.lg,
              110,
            ),
            children: <Widget>[
              _Header(monthLabel: monthLabel),
              const SizedBox(height: AppSpacing.md + AppSpacing.xxs),
              _TotalExpenseCard(
                total: monthTotal,
                income: monthIncome,
                percentage: state.insights?.monthly.percentageChange ?? 0,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppSectionHeader(
                title: context.l10n.categorySplitTitle,
                subtitle: context.l10n.categorySplitSubtitle,
                titleStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                subtitleStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                subtitleSpacing: AppSpacing.xs,
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
                InsightCard(insights: state.insights!),
              const SizedBox(height: AppSpacing.lg),
              AppSectionHeader(
                title: context.l10n.recentTransactionsTitle,
                subtitle: context.l10n.recentTransactionsSubtitle,
                titleStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                subtitleStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                subtitleSpacing: AppSpacing.xs,
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
                            milliseconds: _DashboardMetrics
                                    .recentAnimationBaseMs +
                                (index *
                                    _DashboardMetrics.recentAnimationStaggerMs),
                          ),
                          tween: Tween<double>(begin: 0, end: 1),
                          builder: (BuildContext context, double value,
                              Widget? child) {
                            return Transform.translate(
                              offset: Offset((1 - value) * 36, 0),
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

class _Header extends StatelessWidget {
  const _Header({required this.monthLabel});

  final String monthLabel;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final AuthState auth = context.watch<AuthCubit>().state;
    final String name = (auth.displayName?.trim().isNotEmpty == true
            ? auth.displayName!.trim()
            : auth.username?.trim()) ??
        '';
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              name.isEmpty
                  ? context.l10n.helloDeveloper
                  : context.l10n.helloName(name),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              monthLabel,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
        Container(
          width: _DashboardMetrics.headerActionSize,
          height: _DashboardMetrics.headerActionSize,
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: const Icon(Icons.notifications_none_rounded),
        ),
      ],
    );
  }
}

class _TotalExpenseCard extends StatelessWidget {
  const _TotalExpenseCard({
    required this.total,
    required this.income,
    required this.percentage,
  });

  final double total;
  final double income;
  final double percentage;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final bool increased = percentage >= 0;
    final Color badgeColor =
        increased ? AppTheme.expenseRed : AppTheme.positiveGreen;

    return Container(
      padding: const EdgeInsets.all(_DashboardMetrics.totalCardPadding),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? <Color>[
                  _DashboardColors.totalGradientDarkStart,
                  AppTheme.primary.withValues(alpha: 0.92),
                ]
              : <Color>[
                  AppTheme.primary,
                  _DashboardColors.totalGradientLightEnd,
                ],
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: isDark ? 0.12 : 0.25),
            blurRadius: _DashboardMetrics.totalCardShadowBlur,
            offset: const Offset(0, _DashboardMetrics.totalCardShadowOffsetY),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            context.l10n.totalThisMonth,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            CurrencyFormatter.formatValue(total),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: AppSpacing.sm + AppSpacing.xxs),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm + AppSpacing.xxs,
                  vertical: AppSpacing.sm - AppSpacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? colorScheme.surface.withValues(alpha: 0.95)
                      : Colors.white,
                  borderRadius:
                      BorderRadius.circular(_DashboardMetrics.badgeRadius),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      increased
                          ? Icons.arrow_upward_rounded
                          : Icons.arrow_downward_rounded,
                      size: _DashboardMetrics.badgeIconSize,
                      color: badgeColor,
                    ),
                    const SizedBox(width: AppSpacing.sm - AppSpacing.xxs),
                    Text(
                      context.l10n.summaryVsLastMonth(
                        percentage.abs().toStringAsFixed(1),
                      ),
                      style: TextStyle(
                        color: badgeColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 220),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm + AppSpacing.xxs,
                    vertical: AppSpacing.sm - AppSpacing.xxs,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? colorScheme.surface.withValues(alpha: 0.95)
                        : Colors.white,
                    borderRadius:
                        BorderRadius.circular(_DashboardMetrics.badgeRadius),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(
                        Icons.arrow_downward_rounded,
                        size: _DashboardMetrics.badgeIconSize,
                        color: AppTheme.positiveGreen,
                      ),
                      const SizedBox(width: AppSpacing.sm - AppSpacing.xxs),
                      Flexible(
                        child: Text(
                          '${context.l10n.incomeLabel}: ${CurrencyFormatter.formatValue(income)}',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: const TextStyle(
                            color: AppTheme.positiveGreen,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DashboardColors {
  const _DashboardColors._();

  static const Color totalGradientDarkStart = Color(0xFF1B5E35);
  static const Color totalGradientLightEnd = Color(0xFF4CAF50);
}

class _DashboardMetrics {
  const _DashboardMetrics._();

  static const int recentAnimationBaseMs = 260;
  static const int recentAnimationStaggerMs = 110;

  static const double headerActionSize = 42;
  static const double totalCardPadding = 18;
  static const double totalCardShadowBlur = 18;
  static const double totalCardShadowOffsetY = 12;
  static const double badgeRadius = 20;
  static const double badgeIconSize = 14;
}
