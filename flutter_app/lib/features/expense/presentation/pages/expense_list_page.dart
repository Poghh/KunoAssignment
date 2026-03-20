import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_ui_constants.dart';
import '../../../../core/cubit/settings_cubit.dart';
import '../../../../core/extensions/error_localization_extension.dart';
import '../../../../core/extensions/category_localization_extension.dart';
import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/utils/color_parser.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_loading_state.dart';
import '../../../../core/widgets/app_section_header.dart';
import '../../../../core/widgets/app_surface_card.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../domain/entities/expense.dart';
import '../cubit/expense_list_cubit.dart';
import '../cubit/expense_list_state.dart';
import '../widgets/category_icon_registry.dart';
import '../widgets/expense_card.dart';

class ExpenseListPage extends StatelessWidget {
  const ExpenseListPage({
    required this.onEditExpense,
    super.key,
  });

  final ValueChanged<Expense> onEditExpense;

  @override
  Widget build(BuildContext context) {
    final SettingsState settings = context.watch<SettingsCubit>().state;

    return BlocBuilder<ExpenseListCubit, ExpenseListState>(
      builder: (BuildContext context, ExpenseListState state) {
        return Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg - AppSpacing.xs,
                AppSpacing.lg,
                0,
              ),
              child: _FilterPanel(
                state: state,
                localeCode: settings.localeCode,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Expanded(
              child: _ExpenseListBody(
                state: state,
                onEditExpense: onEditExpense,
                localeCode: settings.localeCode,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _FilterPanel extends StatelessWidget {
  const _FilterPanel({
    required this.state,
    required this.localeCode,
  });

  final ExpenseListState state;
  final String localeCode;

  @override
  Widget build(BuildContext context) {
    final ExpenseListCubit cubit = context.read<ExpenseListCubit>();
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return AppSurfaceCard(
      padding: const EdgeInsets.all(AppSpacing.lg - AppSpacing.xxs),
      radius: AppRadius.xl,
      lightShadow: false,
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              const Spacer(),
              if (state.selectedCategoryId != null ||
                  state.selectedDateRange != null)
                TextButton(
                  onPressed: cubit.clearFilters,
                  child: Text(context.l10n.clearFilters),
                ),
            ],
          ),
          AppSectionHeader(
            title: context.l10n.expensesTitle,
            subtitle: context.l10n.filterByDate,
            titleStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
            subtitleStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: AppSpacing.sm),
          DropdownButtonFormField<String?>(
            value: state.selectedCategoryId,
            decoration: InputDecoration(
              labelText: context.l10n.categoryLabel,
              prefixIcon: const Icon(Icons.category_outlined),
            ),
            items: <DropdownMenuItem<String?>>[
              DropdownMenuItem<String?>(
                value: null,
                child: Text(context.l10n.allCategories),
              ),
              ...state.categories.map(
                (category) => DropdownMenuItem<String?>(
                  value: category.id,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(
                        resolveCategoryIcon(category.icon),
                        size: 18,
                        color: parseHexColor(
                          category.color,
                          fallback: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        context.l10n.localizeCategory(category.name),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
            onChanged: cubit.setCategoryFilter,
          ),
          const SizedBox(height: AppSpacing.sm + AppSpacing.xxs),
          DropdownButtonFormField<ExpenseSortOption>(
            value: state.sortOption,
            decoration: InputDecoration(
              labelText: context.l10n.sortByLabel,
              prefixIcon: const Icon(Icons.sort_rounded),
            ),
            items: <DropdownMenuItem<ExpenseSortOption>>[
              DropdownMenuItem<ExpenseSortOption>(
                value: ExpenseSortOption.latest,
                child: Text(context.l10n.sortLatest),
              ),
              DropdownMenuItem<ExpenseSortOption>(
                value: ExpenseSortOption.oldest,
                child: Text(context.l10n.sortOldest),
              ),
              DropdownMenuItem<ExpenseSortOption>(
                value: ExpenseSortOption.amountHigh,
                child: Text(context.l10n.sortAmountHigh),
              ),
              DropdownMenuItem<ExpenseSortOption>(
                value: ExpenseSortOption.amountLow,
                child: Text(context.l10n.sortAmountLow),
              ),
            ],
            onChanged: (ExpenseSortOption? option) {
              if (option != null) cubit.setSortOption(option);
            },
          ),
          const SizedBox(height: AppSpacing.sm + AppSpacing.xxs),
          Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final DateTimeRange? range = await showDateRangePicker(
                      context: context,
                      firstDate:
                          DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                      initialDateRange: state.selectedDateRange,
                    );

                    if (context.mounted) {
                      cubit.setDateRangeFilter(range);
                    }
                  },
                  icon: const Icon(Icons.date_range_rounded),
                  label: Text(
                    state.selectedDateRange == null
                        ? context.l10n.filterByDate
                        : '${DateFormat('dd MMM', localeCode).format(state.selectedDateRange!.start)} - ${DateFormat('dd MMM', localeCode).format(state.selectedDateRange!.end)}',
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

class _ExpenseListBody extends StatelessWidget {
  const _ExpenseListBody({
    required this.state,
    required this.onEditExpense,
    required this.localeCode,
  });

  final ExpenseListState state;
  final ValueChanged<Expense> onEditExpense;
  final String localeCode;

  @override
  Widget build(BuildContext context) {
    if (state.status == ExpenseListStatus.loading &&
        state.allExpenses.isEmpty) {
      return const AppLoadingState();
    }

    if (state.status == ExpenseListStatus.failure &&
        state.allExpenses.isEmpty) {
      return AppErrorState(
        message: context.localizeErrorMessage(
          state.errorMessage,
          fallback: context.l10n.failedLoadExpenses,
        ),
        onRetry: () => context.read<ExpenseListCubit>().loadExpenses(),
      );
    }

    if (state.filteredExpenses.isEmpty) {
      return AppEmptyState(
        title: context.l10n.noMatchingExpensesTitle,
        description: context.l10n.noMatchingExpensesDescription,
      );
    }

    return RefreshIndicator(
      onRefresh: () =>
          context.read<ExpenseListCubit>().loadExpenses(showLoading: false),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.xs,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        itemCount: state.filteredExpenses.length,
        itemBuilder: (BuildContext context, int index) {
          final Expense expense = state.filteredExpenses[index];
          final Expense? previous =
              index == 0 ? null : state.filteredExpenses[index - 1];
          final bool showHeader =
              previous == null || !_isSameDate(expense.date, previous.date);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (showHeader)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xxs,
                    AppSpacing.sm + AppSpacing.xxs,
                    AppSpacing.xxs,
                    AppSpacing.sm,
                  ),
                  child: Text(
                    DateFormat(
                      'EEEE, dd MMM yyyy',
                      localeCode,
                    ).format(expense.date),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              Dismissible(
                key: ValueKey<String>(expense.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: AppSpacing.xl),
                  margin: const EdgeInsets.only(
                      bottom: AppSpacing.sm + AppSpacing.xxs),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.error,
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                  ),
                  child: const Icon(Icons.delete_outline_rounded,
                      color: Colors.white),
                ),
                confirmDismiss: (_) => showDialog<bool>(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text(context.l10n.deleteExpenseTitle),
                      content: Text(
                        context.l10n.removeExpensePermanently(expense.title),
                      ),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: Text(context.l10n.commonCancel),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: Text(context.l10n.commonDelete),
                        ),
                      ],
                    );
                  },
                ),
                onDismissed: (_) async {
                  final bool deleted = await context
                      .read<ExpenseListCubit>()
                      .deleteExpense(expense.id);
                  if (!context.mounted) {
                    return;
                  }

                  if (deleted) {
                    AppToast.success(context.l10n.expenseDeleted);
                  } else {
                    AppToast.error(context.l10n.deleteExpenseFailed);
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.only(
                      bottom: AppSpacing.sm + AppSpacing.xxs),
                  child: ExpenseCard(
                    expense: expense,
                    category: state.categoryById(expense.categoryId),
                    onTap: () => onEditExpense(expense),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  bool _isSameDate(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }
}
