import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_network_constants.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/expense.dart';
import '../../domain/usecases/delete_expense_usecase.dart';
import '../../domain/usecases/ensure_default_categories_usecase.dart';
import '../../domain/usecases/get_expenses_usecase.dart';
import 'expense_list_state.dart';

class ExpenseListCubit extends Cubit<ExpenseListState> {
  ExpenseListCubit({
    required this.getExpensesUseCase,
    required this.ensureDefaultCategoriesUseCase,
    required this.deleteExpenseUseCase,
  }) : super(const ExpenseListState());

  final GetExpensesUseCase getExpensesUseCase;
  final EnsureDefaultCategoriesUseCase ensureDefaultCategoriesUseCase;
  final DeleteExpenseUseCase deleteExpenseUseCase;

  Future<void> loadExpenses({bool showLoading = true}) async {
    if (showLoading) {
      emit(
        state.copyWith(
          status: ExpenseListStatus.loading,
          errorMessage: null,
        ),
      );
    }

    try {
      final List<dynamic> response = await Future.wait<dynamic>(
        <Future<dynamic>>[
          getExpensesUseCase(),
          ensureDefaultCategoriesUseCase(),
        ],
      );

      final List<Expense> allExpenses = _sortExpenses(
        (response[0] as List<Expense>),
        state.sortOption,
      );
      final List<Category> categories =
          (response[1] as List<dynamic>).cast<Category>();

      emit(
        state.copyWith(
          status: ExpenseListStatus.success,
          allExpenses: allExpenses,
          filteredExpenses: _applyFilters(
            source: allExpenses,
            categoryId: state.selectedCategoryId,
            range: state.selectedDateRange,
            sortOption: state.sortOption,
          ),
          categories: categories,
          errorMessage: null,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: ExpenseListStatus.failure,
          errorMessage: _resolveErrorMessage(error),
        ),
      );
    }
  }

  void setCategoryFilter(String? categoryId) {
    emit(
      state.copyWith(
        selectedCategoryId: categoryId,
        filteredExpenses: _applyFilters(
          source: state.allExpenses,
          categoryId: categoryId,
          range: state.selectedDateRange,
          sortOption: state.sortOption,
        ),
      ),
    );
  }

  void setDateRangeFilter(DateTimeRange? dateRange) {
    emit(
      state.copyWith(
        selectedDateRange: dateRange,
        filteredExpenses: _applyFilters(
          source: state.allExpenses,
          categoryId: state.selectedCategoryId,
          range: dateRange,
          sortOption: state.sortOption,
        ),
      ),
    );
  }

  void setSortOption(ExpenseSortOption option) {
    emit(
      state.copyWith(
        sortOption: option,
        allExpenses: _sortExpenses(state.allExpenses, option),
        filteredExpenses: _applyFilters(
          source: state.allExpenses,
          categoryId: state.selectedCategoryId,
          range: state.selectedDateRange,
          sortOption: option,
        ),
      ),
    );
  }

  void clearFilters() {
    emit(
      state.copyWith(
        selectedCategoryId: null,
        selectedDateRange: null,
        filteredExpenses: _sortExpenses(state.allExpenses, state.sortOption),
      ),
    );
  }

  Future<bool> deleteExpense(String expenseId) async {
    try {
      await deleteExpenseUseCase(expenseId);
      final List<Expense> nextAllExpenses = state.allExpenses
          .where((Expense expense) => expense.id != expenseId)
          .toList(growable: false);

      emit(
        state.copyWith(
          allExpenses: nextAllExpenses,
          filteredExpenses: _applyFilters(
            source: nextAllExpenses,
            categoryId: state.selectedCategoryId,
            range: state.selectedDateRange,
            sortOption: state.sortOption,
          ),
          errorMessage: null,
        ),
      );
      return true;
    } catch (error) {
      emit(
        state.copyWith(
          status: ExpenseListStatus.failure,
          errorMessage: _resolveErrorMessage(error),
        ),
      );
      return false;
    }
  }

  List<Expense> _applyFilters({
    required List<Expense> source,
    required String? categoryId,
    required DateTimeRange? range,
    required ExpenseSortOption sortOption,
  }) {
    final Iterable<Expense> filtered = source.where((Expense expense) {
      final bool categoryMatches = categoryId == null || categoryId.isEmpty
          ? true
          : expense.categoryId == categoryId;

      final bool dateMatches = range == null
          ? true
          : (expense.date
                  .isAfter(range.start.subtract(const Duration(days: 1))) &&
              expense.date.isBefore(range.end.add(const Duration(days: 1))));

      return categoryMatches && dateMatches;
    });

    return _sortExpenses(filtered.toList(growable: false), sortOption);
  }

  List<Expense> _sortExpenses(
    List<Expense> source,
    ExpenseSortOption option,
  ) {
    final List<Expense> sorted = List<Expense>.from(source);
    sorted.sort((Expense first, Expense second) {
      switch (option) {
        case ExpenseSortOption.latest:
          return second.date.compareTo(first.date);
        case ExpenseSortOption.oldest:
          return first.date.compareTo(second.date);
        case ExpenseSortOption.amountHigh:
          return second.amount.abs().compareTo(first.amount.abs());
        case ExpenseSortOption.amountLow:
          return first.amount.abs().compareTo(second.amount.abs());
      }
    });
    return sorted;
  }

  String _resolveErrorMessage(Object error) {
    if (error is DioException) {
      final dynamic data = error.response?.data;
      if (data is Map<String, dynamic> &&
          data[AppApiResponseKey.message] is String) {
        return data[AppApiResponseKey.message] as String;
      }

      return error.message ?? AppApiErrorMessage.requestFailed;
    }

    return AppApiErrorMessage.unknown;
  }
}
