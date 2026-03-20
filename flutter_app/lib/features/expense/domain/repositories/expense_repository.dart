import '../entities/category.dart';
import '../entities/expense.dart';
import '../entities/insight.dart';

abstract class ExpenseRepository {
  Future<List<Expense>> getExpenses({
    String? categoryId,
    DateTime? startDate,
    DateTime? endDate,
  });

  Future<Expense> createExpense(ExpenseDraft draft);

  Future<Expense> updateExpense({
    required String expenseId,
    required ExpenseDraft draft,
  });

  Future<void> deleteExpense(String expenseId);

  Future<List<Category>> getCategories();

  Future<Category> createCategory({
    required String name,
    required String icon,
    String? color,
  });

  Future<void> deleteCategory(String categoryId);

  Future<MonthlyInsight> getMonthlyInsight();

  Future<CategoryInsight> getCategoryInsight();

  Future<DailyAverageInsight> getDailyAverageInsight();

  Future<TopDayInsight> getTopDayInsight();
}
