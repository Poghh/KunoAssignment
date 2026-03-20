import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/category.dart';
import '../../domain/entities/expense.dart';

enum ExpenseListStatus {
  initial,
  loading,
  success,
  failure,
}

enum ExpenseSortOption {
  latest,
  oldest,
  amountHigh,
  amountLow,
}

class ExpenseListState extends Equatable {
  const ExpenseListState({
    this.status = ExpenseListStatus.initial,
    this.allExpenses = const <Expense>[],
    this.filteredExpenses = const <Expense>[],
    this.categories = const <Category>[],
    this.selectedCategoryId,
    this.selectedDateRange,
    this.sortOption = ExpenseSortOption.latest,
    this.errorMessage,
  });

  final ExpenseListStatus status;
  final List<Expense> allExpenses;
  final List<Expense> filteredExpenses;
  final List<Category> categories;
  final String? selectedCategoryId;
  final DateTimeRange? selectedDateRange;
  final ExpenseSortOption sortOption;
  final String? errorMessage;

  Category? categoryById(String categoryId) {
    for (final Category category in categories) {
      if (category.id == categoryId) {
        return category;
      }
    }
    return null;
  }

  static const Object _sentinel = Object();

  ExpenseListState copyWith({
    ExpenseListStatus? status,
    List<Expense>? allExpenses,
    List<Expense>? filteredExpenses,
    List<Category>? categories,
    Object? selectedCategoryId = _sentinel,
    Object? selectedDateRange = _sentinel,
    ExpenseSortOption? sortOption,
    Object? errorMessage = _sentinel,
  }) {
    return ExpenseListState(
      status: status ?? this.status,
      allExpenses: allExpenses ?? this.allExpenses,
      filteredExpenses: filteredExpenses ?? this.filteredExpenses,
      categories: categories ?? this.categories,
      selectedCategoryId: identical(selectedCategoryId, _sentinel)
          ? this.selectedCategoryId
          : selectedCategoryId as String?,
      selectedDateRange: identical(selectedDateRange, _sentinel)
          ? this.selectedDateRange
          : selectedDateRange as DateTimeRange?,
      sortOption: sortOption ?? this.sortOption,
      errorMessage: identical(errorMessage, _sentinel)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        status,
        allExpenses,
        filteredExpenses,
        categories,
        selectedCategoryId,
        selectedDateRange,
        sortOption,
        errorMessage,
      ];
}
