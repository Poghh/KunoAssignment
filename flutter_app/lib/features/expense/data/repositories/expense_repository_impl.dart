import 'dart:async';

import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/category.dart';
import '../../domain/entities/expense.dart';
import '../../domain/entities/insight.dart';
import '../../domain/repositories/expense_repository.dart';
import '../datasources/expense_local_data_source.dart';
import '../datasources/expense_remote_data_source.dart';
import '../models/category_model.dart';
import '../models/expense_model.dart';
import '../models/pending_sync_operation.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  ExpenseRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  final ExpenseRemoteDataSource remoteDataSource;
  final ExpenseLocalDataSource localDataSource;

  Future<void>? _syncInFlight;
  Future<void>? _refreshInFlight;

  @override
  Future<List<Expense>> getExpenses({
    String? categoryId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final List<ExpenseModel> cachedExpenses =
        await localDataSource.getCachedExpenses();

    if (cachedExpenses.isNotEmpty) {
      _triggerBackgroundSyncAndRefresh();
      return _filterExpenses(
        cachedExpenses,
        categoryId: categoryId,
        startDate: startDate,
        endDate: endDate,
      );
    }

    await _synchronizePendingOperations();
    final List<ExpenseModel> remoteExpenses =
        await remoteDataSource.getExpenses();
    await localDataSource.cacheExpenses(remoteExpenses);

    return _filterExpenses(
      remoteExpenses,
      categoryId: categoryId,
      startDate: startDate,
      endDate: endDate,
    );
  }

  @override
  Future<Expense> createExpense(ExpenseDraft draft) async {
    final ExpenseModel localExpense =
        await localDataSource.createExpenseLocally(draft);
    _triggerBackgroundSyncAndRefresh();
    return localExpense;
  }

  @override
  Future<Expense> updateExpense({
    required String expenseId,
    required ExpenseDraft draft,
  }) async {
    final ExpenseModel localExpense =
        await localDataSource.updateExpenseLocally(
      expenseId: expenseId,
      draft: draft,
    );
    _triggerBackgroundSyncAndRefresh();
    return localExpense;
  }

  @override
  Future<void> deleteExpense(String expenseId) async {
    await localDataSource.deleteExpenseLocally(expenseId);
    _triggerBackgroundSyncAndRefresh();
  }

  @override
  Future<List<Category>> getCategories() async {
    final List<CategoryModel> cachedCategories =
        await localDataSource.getCachedCategories();

    if (cachedCategories.isNotEmpty) {
      _triggerBackgroundSyncAndRefresh();
      return _sortedCategories(cachedCategories);
    }

    try {
      await _synchronizePendingOperations();
      final List<CategoryModel> remoteCategories =
          await remoteDataSource.getCategories();
      await localDataSource.cacheCategories(remoteCategories);
      return _sortedCategories(remoteCategories);
    } catch (_) {
      return _sortedCategories(cachedCategories);
    }
  }

  @override
  Future<Category> createCategory({
    required String name,
    required String icon,
    String? color,
  }) async {
    final CategoryModel localCategory =
        await localDataSource.createCategoryLocally(
      name: name,
      icon: icon,
      color: color,
    );
    _triggerBackgroundSyncAndRefresh();
    return localCategory;
  }

  @override
  Future<void> deleteCategory(String categoryId) async {
    await localDataSource.deleteCategoryLocally(categoryId);
    _triggerBackgroundSyncAndRefresh();
  }

  @override
  Future<MonthlyInsight> getMonthlyInsight() async {
    final _InsightSource source = await _loadInsightSource();
    final DateTime now = DateTime.now();
    final _MonthRange thisMonth = _MonthRange.from(now);
    final _MonthRange lastMonth = _MonthRange.from(
      DateTime(now.year, now.month - 1, 1),
    );

    final List<ExpenseModel> thisMonthExpenses = _onlyExpenses(
      _filterByMonth(source.expenses, thisMonth),
    );
    final List<ExpenseModel> lastMonthExpenses = _onlyExpenses(
      _filterByMonth(source.expenses, lastMonth),
    );

    final double totalThisMonth = _sumAmounts(thisMonthExpenses);
    final double totalLastMonth = _sumAmounts(lastMonthExpenses);

    double percentageChange = 0;
    if (totalLastMonth == 0 && totalThisMonth > 0) {
      percentageChange = 100;
    } else if (totalLastMonth > 0) {
      percentageChange = _round2(
        ((totalThisMonth - totalLastMonth) / totalLastMonth) * 100,
      );
    }

    return MonthlyInsight(
      month: DateFormat('MMMM yyyy', 'en_US').format(thisMonth.start),
      totalThisMonth: totalThisMonth,
      totalLastMonth: totalLastMonth,
      percentageChange: percentageChange,
    );
  }

  @override
  Future<CategoryInsight> getCategoryInsight() async {
    final _InsightSource source = await _loadInsightSource();
    final _MonthRange thisMonth = _MonthRange.from(DateTime.now());
    final List<ExpenseModel> thisMonthExpenses = _onlyExpenses(
      _filterByMonth(source.expenses, thisMonth),
    );

    if (thisMonthExpenses.isEmpty) {
      return const CategoryInsight(
        categoryName: null,
        total: 0,
        percentageOfMonth: 0,
      );
    }

    final Map<String, double> grouped = <String, double>{};
    for (final ExpenseModel expense in thisMonthExpenses) {
      grouped[expense.categoryId] =
          (grouped[expense.categoryId] ?? 0) + expense.amount;
    }

    String? topCategoryId;
    double topCategoryTotal = 0;

    grouped.forEach((String categoryId, double total) {
      if (topCategoryId == null || total > topCategoryTotal) {
        topCategoryId = categoryId;
        topCategoryTotal = total;
      }
    });

    final double monthTotal = _sumAmounts(thisMonthExpenses);
    final CategoryModel? category =
        source.categories.cast<CategoryModel?>().firstWhere(
              (CategoryModel? item) => item?.id == topCategoryId,
              orElse: () => null,
            );

    return CategoryInsight(
      categoryName: category?.name ?? 'Unknown',
      total: monthTotal,
      percentageOfMonth:
          monthTotal == 0 ? 0 : _round2((topCategoryTotal / monthTotal) * 100),
    );
  }

  @override
  Future<DailyAverageInsight> getDailyAverageInsight() async {
    final _InsightSource source = await _loadInsightSource();
    final _MonthRange thisMonth = _MonthRange.from(DateTime.now());
    final List<ExpenseModel> thisMonthExpenses = _onlyExpenses(
      _filterByMonth(source.expenses, thisMonth),
    );

    final double totalThisMonth = _sumAmounts(thisMonthExpenses);
    final int daysElapsed = DateTime.now().day;

    final Set<String> activeExpenseDays = thisMonthExpenses
        .map((ExpenseModel expense) => _dateKey(expense.date))
        .toSet();

    return DailyAverageInsight(
      dailyAverage:
          daysElapsed == 0 ? 0 : _round2(totalThisMonth / daysElapsed),
      totalThisMonth: totalThisMonth,
      daysElapsed: daysElapsed,
      activeExpenseDays: activeExpenseDays.length,
    );
  }

  @override
  Future<TopDayInsight> getTopDayInsight() async {
    final _InsightSource source = await _loadInsightSource();
    final _MonthRange thisMonth = _MonthRange.from(DateTime.now());
    final List<ExpenseModel> thisMonthExpenses = _onlyExpenses(
      _filterByMonth(source.expenses, thisMonth),
    );

    if (thisMonthExpenses.isEmpty) {
      return const TopDayInsight(
        topDay: null,
        weekday: null,
        total: 0,
      );
    }

    final Map<String, double> groupedByDay = <String, double>{};
    for (final ExpenseModel expense in thisMonthExpenses) {
      final String day = _dateKey(expense.date);
      groupedByDay[day] = (groupedByDay[day] ?? 0) + expense.amount;
    }

    String? topDay;
    double topTotal = 0;

    groupedByDay.forEach((String day, double total) {
      if (topDay == null || total > topTotal) {
        topDay = day;
        topTotal = total;
      }
    });

    if (topDay == null) {
      return const TopDayInsight(
        topDay: null,
        weekday: null,
        total: 0,
      );
    }

    final DateTime resolvedTopDay = DateTime.parse(topDay!);

    return TopDayInsight(
      topDay: resolvedTopDay,
      weekday: DateFormat('EEEE', 'en_US').format(resolvedTopDay),
      total: _round2(topTotal),
    );
  }

  Future<_InsightSource> _loadInsightSource() async {
    List<ExpenseModel> expenses = await localDataSource.getCachedExpenses();
    List<CategoryModel> categories =
        await localDataSource.getCachedCategories();

    if (expenses.isEmpty && categories.isEmpty) {
      try {
        await _synchronizePendingOperations();
        await _refreshRemoteCache();
        expenses = await localDataSource.getCachedExpenses();
        categories = await localDataSource.getCachedCategories();
      } catch (_) {
        // Keep current local state.
      }
    } else {
      _triggerBackgroundSyncAndRefresh();
    }

    return _InsightSource(
      expenses: expenses,
      categories: categories,
    );
  }

  Future<void> _synchronizePendingOperations() {
    final Future<void>? currentSync = _syncInFlight;
    if (currentSync != null) {
      return currentSync;
    }

    final Future<void> nextSync = _runSynchronization();
    _syncInFlight = nextSync;

    return nextSync.whenComplete(() {
      if (identical(_syncInFlight, nextSync)) {
        _syncInFlight = null;
      }
    });
  }

  Future<void> _runSynchronization() async {
    final List<PendingSyncOperation> queue = List<PendingSyncOperation>.from(
        await localDataSource.getPendingOperations());

    while (queue.isNotEmpty) {
      final PendingSyncOperation operation = queue.first;

      try {
        await _processSyncOperation(operation, queue);
        queue.removeAt(0);
        await localDataSource.savePendingOperations(queue);
      } on DioException catch (error) {
        if (_isConnectivityError(error)) {
          await localDataSource.savePendingOperations(queue);
          rethrow;
        }

        await _handleRecoverableSyncFailure(
          operation: operation,
          error: error,
          queue: queue,
        );
        queue.removeAt(0);
        await localDataSource.savePendingOperations(queue);
      } catch (_) {
        queue.removeAt(0);
        await localDataSource.savePendingOperations(queue);
      }
    }
  }

  Future<void> _processSyncOperation(
    PendingSyncOperation operation,
    List<PendingSyncOperation> queue,
  ) async {
    switch (operation.type) {
      case PendingSyncOperationType.createCategory:
        await _syncCreateCategory(operation, queue);
        return;
      case PendingSyncOperationType.deleteCategory:
        await remoteDataSource.deleteCategory(operation.entityId);
        return;
      case PendingSyncOperationType.createExpense:
        await _syncCreateExpense(operation, queue);
        return;
      case PendingSyncOperationType.updateExpense:
        await _syncUpdateExpense(operation);
        return;
      case PendingSyncOperationType.deleteExpense:
        await remoteDataSource.deleteExpense(operation.entityId);
        return;
    }
  }

  Future<void> _syncCreateCategory(
    PendingSyncOperation operation,
    List<PendingSyncOperation> queue,
  ) async {
    final String name = ((operation.payload['name'] as String?) ?? '').trim();
    final String icon = ((operation.payload['icon'] as String?) ?? '').trim();
    final String? color = operation.payload['color'] as String?;

    if (name.isEmpty || icon.isEmpty) {
      return;
    }

    final CategoryModel createdCategory = await remoteDataSource.createCategory(
      name: name,
      icon: icon,
      color: color,
    );

    await localDataSource.replaceCategoryIdAcrossStorage(
      fromId: operation.entityId,
      toId: createdCategory.id,
    );
    _replaceCategoryIdInPendingQueue(
      queue,
      fromId: operation.entityId,
      toId: createdCategory.id,
    );
    await localDataSource.upsertCategory(createdCategory);
  }

  Future<void> _syncCreateExpense(
    PendingSyncOperation operation,
    List<PendingSyncOperation> queue,
  ) async {
    final ExpenseDraft draft = operation.toExpenseDraft();
    if (!_isValidDraft(draft)) {
      return;
    }

    final ExpenseModel createdExpense =
        await remoteDataSource.createExpense(draft);
    await localDataSource.replaceExpenseIdAcrossStorage(
      fromId: operation.entityId,
      toId: createdExpense.id,
    );
    _replaceExpenseIdInPendingQueue(
      queue,
      fromId: operation.entityId,
      toId: createdExpense.id,
    );
    await localDataSource.upsertExpense(createdExpense);
  }

  Future<void> _syncUpdateExpense(PendingSyncOperation operation) async {
    final ExpenseDraft draft = operation.toExpenseDraft();
    if (!_isValidDraft(draft)) {
      return;
    }

    final ExpenseModel updatedExpense = await remoteDataSource.updateExpense(
      expenseId: operation.entityId,
      draft: draft,
    );
    await localDataSource.upsertExpense(updatedExpense);
  }

  Future<void> _handleRecoverableSyncFailure({
    required PendingSyncOperation operation,
    required DioException error,
    required List<PendingSyncOperation> queue,
  }) async {
    final int? statusCode = error.response?.statusCode;

    if (operation.type == PendingSyncOperationType.deleteExpense &&
        statusCode == 404) {
      return;
    }

    if (operation.type == PendingSyncOperationType.deleteCategory &&
        statusCode == 404) {
      return;
    }

    if (operation.type == PendingSyncOperationType.updateExpense &&
        statusCode == 404) {
      await localDataSource.removeExpense(operation.entityId);
      return;
    }

    if (operation.type == PendingSyncOperationType.createCategory &&
        statusCode == 409) {
      final String categoryName =
          ((operation.payload['name'] as String?) ?? '').trim().toLowerCase();
      if (categoryName.isEmpty) {
        return;
      }

      final List<CategoryModel> remoteCategories =
          await remoteDataSource.getCategories();
      final CategoryModel? matchedCategory =
          remoteCategories.cast<CategoryModel?>().firstWhere(
                (CategoryModel? category) =>
                    category?.name.trim().toLowerCase() == categoryName,
                orElse: () => null,
              );

      if (matchedCategory != null) {
        await localDataSource.replaceCategoryIdAcrossStorage(
          fromId: operation.entityId,
          toId: matchedCategory.id,
        );
        _replaceCategoryIdInPendingQueue(
          queue,
          fromId: operation.entityId,
          toId: matchedCategory.id,
        );
      }

      await localDataSource.cacheCategories(remoteCategories);
      return;
    }

    if (operation.type == PendingSyncOperationType.deleteCategory &&
        statusCode == 409) {
      final List<CategoryModel> remoteCategories =
          await remoteDataSource.getCategories();
      await localDataSource.cacheCategories(remoteCategories);
    }
  }

  void _replaceExpenseIdInPendingQueue(
    List<PendingSyncOperation> queue, {
    required String fromId,
    required String toId,
  }) {
    if (fromId == toId) {
      return;
    }

    for (int index = 0; index < queue.length; index++) {
      final PendingSyncOperation operation = queue[index];
      if ((operation.type == PendingSyncOperationType.createExpense ||
              operation.type == PendingSyncOperationType.updateExpense ||
              operation.type == PendingSyncOperationType.deleteExpense) &&
          operation.entityId == fromId) {
        queue[index] = operation.copyWith(entityId: toId);
      }
    }
  }

  void _replaceCategoryIdInPendingQueue(
    List<PendingSyncOperation> queue, {
    required String fromId,
    required String toId,
  }) {
    if (fromId == toId) {
      return;
    }

    for (int index = 0; index < queue.length; index++) {
      PendingSyncOperation operation = queue[index];

      if (operation.type == PendingSyncOperationType.createCategory &&
          operation.entityId == fromId) {
        operation = operation.copyWith(entityId: toId);
      }
      if (operation.type == PendingSyncOperationType.deleteCategory &&
          operation.entityId == fromId) {
        operation = operation.copyWith(entityId: toId);
      }

      if (operation.type == PendingSyncOperationType.createExpense ||
          operation.type == PendingSyncOperationType.updateExpense) {
        final String? categoryId = operation.payload['categoryId'] as String?;
        if (categoryId == fromId) {
          operation = operation.copyWith(
            payload: <String, dynamic>{
              ...operation.payload,
              'categoryId': toId,
            },
          );
        }
      }

      queue[index] = operation;
    }
  }

  bool _isValidDraft(ExpenseDraft draft) {
    return draft.title.trim().length >= 2 &&
        draft.categoryId.trim().isNotEmpty &&
        draft.amount != 0;
  }

  bool _isConnectivityError(DioException error) {
    if (error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return true;
    }

    if (error.type == DioExceptionType.unknown && error.response == null) {
      return true;
    }

    return false;
  }

  void _triggerBackgroundSyncAndRefresh() {
    unawaited(_runBackgroundSyncAndRefresh());
  }

  Future<void> _runBackgroundSyncAndRefresh() async {
    try {
      await _synchronizePendingOperations();
      await _refreshRemoteCache();
    } catch (_) {
      // Keep local-first UX even when background sync fails.
    }
  }

  Future<void> _refreshRemoteCache() {
    final Future<void>? currentRefresh = _refreshInFlight;
    if (currentRefresh != null) {
      return currentRefresh;
    }

    final Future<void> nextRefresh = _runRemoteRefresh();
    _refreshInFlight = nextRefresh;

    return nextRefresh.whenComplete(() {
      if (identical(_refreshInFlight, nextRefresh)) {
        _refreshInFlight = null;
      }
    });
  }

  Future<void> _runRemoteRefresh() async {
    final List<dynamic> response = await Future.wait<dynamic>(
      <Future<dynamic>>[
        remoteDataSource.getExpenses(),
        remoteDataSource.getCategories(),
      ],
    );

    final List<ExpenseModel> expenses =
        (response[0] as List<dynamic>).cast<ExpenseModel>();
    final List<CategoryModel> categories =
        (response[1] as List<dynamic>).cast<CategoryModel>();

    await localDataSource.cacheExpenses(expenses);
    await localDataSource.cacheCategories(categories);
  }

  List<Expense> _filterExpenses(
    List<ExpenseModel> source, {
    String? categoryId,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    final DateTime? normalizedStart = startDate == null
        ? null
        : DateTime(startDate.year, startDate.month, startDate.day);
    final DateTime? normalizedEnd = endDate == null
        ? null
        : DateTime(endDate.year, endDate.month, endDate.day);

    final List<ExpenseModel> filtered = source.where((ExpenseModel expense) {
      final bool categoryMatched = categoryId == null ||
          categoryId.isEmpty ||
          expense.categoryId == categoryId;

      final DateTime expenseDay =
          DateTime(expense.date.year, expense.date.month, expense.date.day);
      final bool startMatched =
          normalizedStart == null || !expenseDay.isBefore(normalizedStart);
      final bool endMatched =
          normalizedEnd == null || !expenseDay.isAfter(normalizedEnd);

      return categoryMatched && startMatched && endMatched;
    }).toList(growable: false);

    filtered.sort((ExpenseModel first, ExpenseModel second) {
      return second.date.compareTo(first.date);
    });

    return filtered;
  }

  List<Category> _sortedCategories(List<CategoryModel> source) {
    final List<CategoryModel> sorted = List<CategoryModel>.from(source);
    sorted.sort((CategoryModel first, CategoryModel second) {
      return first.name.compareTo(second.name);
    });
    return sorted;
  }

  List<ExpenseModel> _filterByMonth(
    List<ExpenseModel> source,
    _MonthRange monthRange,
  ) {
    return source.where((ExpenseModel expense) {
      final DateTime day = DateTime(
        expense.date.year,
        expense.date.month,
        expense.date.day,
      );
      return !day.isBefore(monthRange.start) &&
          day.isBefore(monthRange.endExclusive);
    }).toList(growable: false);
  }

  List<ExpenseModel> _onlyExpenses(List<ExpenseModel> source) {
    return source
        .where((ExpenseModel expense) => expense.amount > 0)
        .toList(growable: false);
  }

  double _sumAmounts(List<ExpenseModel> source) {
    double total = 0;
    for (final ExpenseModel expense in source) {
      total += expense.amount;
    }
    return _round2(total);
  }

  String _dateKey(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  double _round2(num value) {
    return double.parse(value.toStringAsFixed(2));
  }
}

class _InsightSource {
  const _InsightSource({
    required this.expenses,
    required this.categories,
  });

  final List<ExpenseModel> expenses;
  final List<CategoryModel> categories;
}

class _MonthRange {
  const _MonthRange({
    required this.start,
    required this.endExclusive,
  });

  final DateTime start;
  final DateTime endExclusive;

  factory _MonthRange.from(DateTime reference) {
    final DateTime start = DateTime(reference.year, reference.month, 1);
    final DateTime endExclusive =
        DateTime(reference.year, reference.month + 1, 1);
    return _MonthRange(
      start: start,
      endExclusive: endExclusive,
    );
  }
}
