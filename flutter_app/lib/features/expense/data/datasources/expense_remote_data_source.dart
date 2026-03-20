import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_network_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/expense.dart';
import '../models/category_model.dart';
import '../models/expense_model.dart';
import '../models/insight_model.dart';

abstract class ExpenseRemoteDataSource {
  Future<List<ExpenseModel>> getExpenses({
    String? categoryId,
    DateTime? startDate,
    DateTime? endDate,
  });

  Future<ExpenseModel> createExpense(ExpenseDraft draft);

  Future<ExpenseModel> updateExpense({
    required String expenseId,
    required ExpenseDraft draft,
  });

  Future<void> deleteExpense(String expenseId);

  Future<List<CategoryModel>> getCategories();

  Future<CategoryModel> createCategory({
    required String name,
    required String icon,
    String? color,
  });

  Future<void> deleteCategory(String categoryId);

  Future<MonthlyInsightModel> getMonthlyInsight();

  Future<CategoryInsightModel> getCategoryInsight();

  Future<DailyAverageInsightModel> getDailyAverageInsight();

  Future<TopDayInsightModel> getTopDayInsight();
}

class ExpenseRemoteDataSourceImpl implements ExpenseRemoteDataSource {
  ExpenseRemoteDataSourceImpl({required this.apiClient});

  final ApiClient apiClient;

  @override
  Future<List<ExpenseModel>> getExpenses({
    String? categoryId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final Map<String, dynamic> query = <String, dynamic>{
      if (categoryId != null && categoryId.isNotEmpty)
        _ExpenseApiKey.categoryId: categoryId,
      if (startDate != null)
        _ExpenseApiKey.startDate:
            DateFormat(_ExpenseApiKey.dateFormat).format(startDate),
      if (endDate != null)
        _ExpenseApiKey.endDate:
            DateFormat(_ExpenseApiKey.dateFormat).format(endDate),
    };

    final Response<dynamic> response =
        await apiClient.get(AppApiPath.expenses, queryParameters: query);
    final List<dynamic> rawList = (response.data
        as Map<String, dynamic>)[AppApiResponseKey.data] as List<dynamic>;

    return rawList
        .map((dynamic item) =>
            ExpenseModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<ExpenseModel> createExpense(ExpenseDraft draft) async {
    final Response<dynamic> response = await apiClient.post(
      AppApiPath.expenses,
      data: ExpenseModel.draftToJson(draft),
    );

    return ExpenseModel.fromJson(
      (response.data as Map<String, dynamic>)[AppApiResponseKey.data]
          as Map<String, dynamic>,
    );
  }

  @override
  Future<ExpenseModel> updateExpense({
    required String expenseId,
    required ExpenseDraft draft,
  }) async {
    final Response<dynamic> response = await apiClient.put(
      AppApiPath.expenseById(expenseId),
      data: ExpenseModel.draftToJson(draft),
    );

    return ExpenseModel.fromJson(
      (response.data as Map<String, dynamic>)[AppApiResponseKey.data]
          as Map<String, dynamic>,
    );
  }

  @override
  Future<void> deleteExpense(String expenseId) async {
    await apiClient.delete(AppApiPath.expenseById(expenseId));
  }

  @override
  Future<List<CategoryModel>> getCategories() async {
    final Response<dynamic> response =
        await apiClient.get(AppApiPath.categories);
    final List<dynamic> rawList = (response.data
        as Map<String, dynamic>)[AppApiResponseKey.data] as List<dynamic>;

    return rawList
        .map((dynamic item) =>
            CategoryModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<CategoryModel> createCategory({
    required String name,
    required String icon,
    String? color,
  }) async {
    final Response<dynamic> response = await apiClient.post(
      AppApiPath.categories,
      data: <String, dynamic>{
        _ExpenseApiKey.name: name,
        _ExpenseApiKey.icon: icon,
        if (color != null && color.trim().isNotEmpty)
          _ExpenseApiKey.color: color,
      },
    );

    return CategoryModel.fromJson(
      (response.data as Map<String, dynamic>)[AppApiResponseKey.data]
          as Map<String, dynamic>,
    );
  }

  @override
  Future<void> deleteCategory(String categoryId) async {
    await apiClient.delete(AppApiPath.categoryById(categoryId));
  }

  @override
  Future<MonthlyInsightModel> getMonthlyInsight() async {
    final Response<dynamic> response =
        await apiClient.get(AppApiPath.insightsMonthly);
    return MonthlyInsightModel.fromJson(
      (response.data as Map<String, dynamic>)[AppApiResponseKey.data]
          as Map<String, dynamic>,
    );
  }

  @override
  Future<CategoryInsightModel> getCategoryInsight() async {
    final Response<dynamic> response =
        await apiClient.get(AppApiPath.insightsCategory);
    return CategoryInsightModel.fromJson(
      (response.data as Map<String, dynamic>)[AppApiResponseKey.data]
          as Map<String, dynamic>,
    );
  }

  @override
  Future<DailyAverageInsightModel> getDailyAverageInsight() async {
    final Response<dynamic> response =
        await apiClient.get(AppApiPath.insightsDailyAverage);
    return DailyAverageInsightModel.fromJson(
      (response.data as Map<String, dynamic>)[AppApiResponseKey.data]
          as Map<String, dynamic>,
    );
  }

  @override
  Future<TopDayInsightModel> getTopDayInsight() async {
    final Response<dynamic> response =
        await apiClient.get(AppApiPath.insightsTopDay);
    return TopDayInsightModel.fromJson(
      (response.data as Map<String, dynamic>)[AppApiResponseKey.data]
          as Map<String, dynamic>,
    );
  }
}

class _ExpenseApiKey {
  const _ExpenseApiKey._();

  static const String categoryId = 'categoryId';
  static const String startDate = 'startDate';
  static const String endDate = 'endDate';
  static const String dateFormat = 'yyyy-MM-dd';
  static const String name = 'name';
  static const String icon = 'icon';
  static const String color = 'color';
}
