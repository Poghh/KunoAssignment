import 'package:equatable/equatable.dart';

import '../../domain/entities/category.dart';
import '../../domain/entities/expense.dart';
import '../../domain/entities/insight.dart';

enum DashboardStatus {
  initial,
  loading,
  success,
  failure,
}

class DashboardState extends Equatable {
  const DashboardState({
    this.status = DashboardStatus.initial,
    this.allExpenses = const <Expense>[],
    this.categories = const <Category>[],
    this.insights,
    this.errorMessage,
  });

  final DashboardStatus status;
  final List<Expense> allExpenses;
  final List<Category> categories;
  final DashboardInsights? insights;
  final String? errorMessage;

  List<Expense> get recentExpenses {
    if (allExpenses.length <= 5) {
      return allExpenses;
    }

    return allExpenses.take(5).toList(growable: false);
  }

  Category? categoryById(String categoryId) {
    for (final Category category in categories) {
      if (category.id == categoryId) {
        return category;
      }
    }
    return null;
  }

  static const Object _sentinel = Object();

  DashboardState copyWith({
    DashboardStatus? status,
    List<Expense>? allExpenses,
    List<Category>? categories,
    Object? insights = _sentinel,
    Object? errorMessage = _sentinel,
  }) {
    return DashboardState(
      status: status ?? this.status,
      allExpenses: allExpenses ?? this.allExpenses,
      categories: categories ?? this.categories,
      insights: identical(insights, _sentinel)
          ? this.insights
          : insights as DashboardInsights?,
      errorMessage: identical(errorMessage, _sentinel)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  @override
  List<Object?> get props =>
      <Object?>[status, allExpenses, categories, insights, errorMessage];
}
