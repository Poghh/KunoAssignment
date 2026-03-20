import 'dart:convert';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_network_constants.dart';
import '../../domain/entities/expense.dart';
import '../models/category_model.dart';
import '../models/expense_model.dart';
import '../models/pending_sync_operation.dart';

abstract class ExpenseLocalDataSource {
  Future<List<ExpenseModel>> getCachedExpenses();

  Future<List<CategoryModel>> getCachedCategories();

  Future<void> cacheExpenses(List<ExpenseModel> expenses);

  Future<void> cacheCategories(List<CategoryModel> categories);

  Future<ExpenseModel> createExpenseLocally(ExpenseDraft draft);

  Future<ExpenseModel> updateExpenseLocally({
    required String expenseId,
    required ExpenseDraft draft,
  });

  Future<void> deleteExpenseLocally(String expenseId);

  Future<CategoryModel> createCategoryLocally({
    required String name,
    required String icon,
    String? color,
  });

  Future<void> deleteCategoryLocally(String categoryId);

  Future<List<PendingSyncOperation>> getPendingOperations();

  Future<void> savePendingOperations(List<PendingSyncOperation> operations);

  Future<void> upsertExpense(ExpenseModel expense);

  Future<void> upsertCategory(CategoryModel category);

  Future<void> removeExpense(String expenseId);

  Future<void> replaceExpenseIdAcrossStorage({
    required String fromId,
    required String toId,
  });

  Future<void> replaceCategoryIdAcrossStorage({
    required String fromId,
    required String toId,
  });

  /// Migrates all guest-scoped data (pending ops, expenses, categories)
  /// into [authenticatedUsername]'s namespace and clears the guest namespace.
  Future<void> migrateGuestDataToUser(String authenticatedUsername);

  /// Clears the current user's cached expenses and categories, keeping the
  /// pending operations queue intact so they can still be synced to the server.
  Future<void> clearLocalCache();

  /// Seeds hard-coded default categories (with fixed offline IDs) into the
  /// local cache WITHOUT adding pending sync operations.  Only adds categories
  /// that are missing.  Does nothing when server-origin categories are already
  /// cached (i.e. any category whose ID does not start with the offline-default
  /// prefix), to avoid duplicating server data.
  Future<void> seedOfflineDefaultCategories();

  /// The prefix used for all hard-coded offline-default category IDs.
  static const String offlineDefaultPrefix = 'offline-default-';

  /// The canonical list of default categories that are always available
  /// offline.  Matches the seeds on the backend so ID remapping works by name.
  static const List<Map<String, String>> offlineDefaultSeeds =
      <Map<String, String>>[
    <String, String>{
      'id': 'offline-default-food',
      'name': 'Food',
      'icon': 'restaurant',
      'color': '#EF5350',
    },
    <String, String>{
      'id': 'offline-default-transport',
      'name': 'Transport',
      'icon': 'directions_car',
      'color': '#42A5F5',
    },
    <String, String>{
      'id': 'offline-default-shopping',
      'name': 'Shopping',
      'icon': 'shopping_bag',
      'color': '#AB47BC',
    },
    <String, String>{
      'id': 'offline-default-bills',
      'name': 'Bills',
      'icon': 'lightbulb',
      'color': '#FFA726',
    },
    <String, String>{
      'id': 'offline-default-entertainment',
      'name': 'Entertainment',
      'icon': 'movie',
      'color': '#26A69A',
    },
    <String, String>{
      'id': 'offline-default-health',
      'name': 'Health',
      'icon': 'health_and_safety',
      'color': '#66BB6A',
    },
    <String, String>{
      'id': 'offline-default-salary',
      'name': 'Salary',
      'icon': 'work',
      'color': '#4CAF50',
    },
  ];
}

class ExpenseLocalDataSourceImpl implements ExpenseLocalDataSource {
  ExpenseLocalDataSourceImpl({SharedPreferences? preferences})
      : _preferences = preferences;

  final SharedPreferences? _preferences;

  static const String _storageNamespace = 'expense.offline.v1';
  static const double _usdToVnd = 25500;
  static const String _categoryInUseMessage =
      'Cannot delete category with existing transactions';
  static final Random _random = Random();

  @override
  Future<List<ExpenseModel>> getCachedExpenses() async {
    final SharedPreferences prefs = await _resolvePreferences();
    final List<Map<String, dynamic>> rawList =
        await _readJsonList(prefs, await _expenseKey(prefs));

    final List<ExpenseModel> expenses = <ExpenseModel>[];
    for (final Map<String, dynamic> item in rawList) {
      try {
        expenses.add(ExpenseModel.fromJson(item));
      } catch (_) {
        // Ignore malformed items.
      }
    }

    return expenses;
  }

  @override
  Future<List<CategoryModel>> getCachedCategories() async {
    final SharedPreferences prefs = await _resolvePreferences();
    final List<Map<String, dynamic>> rawList =
        await _readJsonList(prefs, await _categoryKey(prefs));

    final List<CategoryModel> categories = <CategoryModel>[];
    for (final Map<String, dynamic> item in rawList) {
      try {
        categories.add(CategoryModel.fromJson(item));
      } catch (_) {
        // Ignore malformed items.
      }
    }

    return categories;
  }

  @override
  Future<void> cacheExpenses(List<ExpenseModel> expenses) async {
    final SharedPreferences prefs = await _resolvePreferences();
    await _writeExpenses(prefs, expenses);
  }

  @override
  Future<void> cacheCategories(List<CategoryModel> categories) async {
    final SharedPreferences prefs = await _resolvePreferences();
    await _writeCategories(prefs, categories);
  }

  @override
  Future<ExpenseModel> createExpenseLocally(ExpenseDraft draft) async {
    final SharedPreferences prefs = await _resolvePreferences();
    final List<ExpenseModel> cachedExpenses = await getCachedExpenses();
    final List<PendingSyncOperation> queue = await getPendingOperations();

    final String localExpenseId = _generateLocalId('expense');
    final ExpenseModel localExpense = _expenseFromDraft(
      expenseId: localExpenseId,
      draft: draft,
    );

    _upsertExpenseInList(cachedExpenses, localExpense);
    queue.add(
      PendingSyncOperation(
        id: _generateOperationId(),
        type: PendingSyncOperationType.createExpense,
        entityId: localExpenseId,
        payload: ExpenseModel.draftToJson(draft),
        createdAt: DateTime.now(),
      ),
    );

    await _writeExpenses(prefs, cachedExpenses);
    await _writeQueue(prefs, queue);

    return localExpense;
  }

  @override
  Future<ExpenseModel> updateExpenseLocally({
    required String expenseId,
    required ExpenseDraft draft,
  }) async {
    final SharedPreferences prefs = await _resolvePreferences();
    final List<ExpenseModel> cachedExpenses = await getCachedExpenses();
    final List<PendingSyncOperation> queue = await getPendingOperations();

    final ExpenseModel updatedExpense = _expenseFromDraft(
      expenseId: expenseId,
      draft: draft,
    );
    _upsertExpenseInList(cachedExpenses, updatedExpense);

    final int createIndex = queue.indexWhere(
      (PendingSyncOperation operation) =>
          operation.type == PendingSyncOperationType.createExpense &&
          operation.entityId == expenseId,
    );

    if (createIndex >= 0) {
      queue[createIndex] = queue[createIndex].copyWith(
        payload: ExpenseModel.draftToJson(draft),
      );
    } else {
      final int updateIndex = queue.indexWhere(
        (PendingSyncOperation operation) =>
            operation.type == PendingSyncOperationType.updateExpense &&
            operation.entityId == expenseId,
      );

      if (updateIndex >= 0) {
        queue[updateIndex] = queue[updateIndex].copyWith(
          payload: ExpenseModel.draftToJson(draft),
        );
      } else {
        queue.add(
          PendingSyncOperation(
            id: _generateOperationId(),
            type: PendingSyncOperationType.updateExpense,
            entityId: expenseId,
            payload: ExpenseModel.draftToJson(draft),
            createdAt: DateTime.now(),
          ),
        );
      }
    }

    await _writeExpenses(prefs, cachedExpenses);
    await _writeQueue(prefs, queue);

    return updatedExpense;
  }

  @override
  Future<void> deleteExpenseLocally(String expenseId) async {
    final SharedPreferences prefs = await _resolvePreferences();
    final List<ExpenseModel> cachedExpenses = await getCachedExpenses();
    final List<PendingSyncOperation> queue = await getPendingOperations();

    cachedExpenses
        .removeWhere((ExpenseModel expense) => expense.id == expenseId);

    final bool hasPendingCreate = queue.any(
      (PendingSyncOperation operation) =>
          operation.type == PendingSyncOperationType.createExpense &&
          operation.entityId == expenseId,
    );

    queue.removeWhere(
      (PendingSyncOperation operation) =>
          operation.entityId == expenseId &&
          (operation.type == PendingSyncOperationType.createExpense ||
              operation.type == PendingSyncOperationType.updateExpense),
    );

    if (!hasPendingCreate) {
      final bool alreadyQueued = queue.any(
        (PendingSyncOperation operation) =>
            operation.type == PendingSyncOperationType.deleteExpense &&
            operation.entityId == expenseId,
      );

      if (!alreadyQueued) {
        queue.add(
          PendingSyncOperation(
            id: _generateOperationId(),
            type: PendingSyncOperationType.deleteExpense,
            entityId: expenseId,
            payload: <String, dynamic>{},
            createdAt: DateTime.now(),
          ),
        );
      }
    }

    await _writeExpenses(prefs, cachedExpenses);
    await _writeQueue(prefs, queue);
  }

  @override
  Future<CategoryModel> createCategoryLocally({
    required String name,
    required String icon,
    String? color,
  }) async {
    final SharedPreferences prefs = await _resolvePreferences();
    final List<CategoryModel> cachedCategories = await getCachedCategories();
    final List<PendingSyncOperation> queue = await getPendingOperations();

    final String normalizedName = name.trim();
    final String normalizedIcon = icon.trim();
    final String normalizedColor =
        (color == null || color.trim().isEmpty) ? '#4CAF50' : color.trim();

    final CategoryModel? existingCategory = _findCategoryByName(
      cachedCategories,
      normalizedName,
    );
    if (existingCategory != null) {
      return existingCategory;
    }

    final String localCategoryId = _generateLocalId('category');
    final CategoryModel localCategory = CategoryModel(
      id: localCategoryId,
      name: normalizedName,
      color: normalizedColor,
      icon: normalizedIcon,
    );

    _upsertCategoryInList(cachedCategories, localCategory);
    queue.add(
      PendingSyncOperation(
        id: _generateOperationId(),
        type: PendingSyncOperationType.createCategory,
        entityId: localCategoryId,
        payload: <String, dynamic>{
          'name': normalizedName,
          'icon': normalizedIcon,
          'color': normalizedColor,
        },
        createdAt: DateTime.now(),
      ),
    );

    await _writeCategories(prefs, cachedCategories);
    await _writeQueue(prefs, queue);

    return localCategory;
  }

  @override
  Future<void> deleteCategoryLocally(String categoryId) async {
    final SharedPreferences prefs = await _resolvePreferences();
    final List<CategoryModel> cachedCategories = await getCachedCategories();
    final List<ExpenseModel> cachedExpenses = await getCachedExpenses();
    final List<PendingSyncOperation> queue = await getPendingOperations();

    final bool categoryExists = cachedCategories
        .any((CategoryModel category) => category.id == categoryId);
    if (!categoryExists) {
      return;
    }

    final bool isInUse = cachedExpenses
        .any((ExpenseModel expense) => expense.categoryId == categoryId);
    if (isInUse) {
      throw StateError(_categoryInUseMessage);
    }

    cachedCategories
        .removeWhere((CategoryModel category) => category.id == categoryId);

    // Offline-default categories only exist locally — never enqueue a server
    // delete for them.
    final bool isOfflineDefault =
        categoryId.startsWith(ExpenseLocalDataSource.offlineDefaultPrefix);

    if (!isOfflineDefault) {
      final bool hasPendingCreate = queue.any(
        (PendingSyncOperation operation) =>
            operation.type == PendingSyncOperationType.createCategory &&
            operation.entityId == categoryId,
      );

      queue.removeWhere(
        (PendingSyncOperation operation) =>
            operation.type == PendingSyncOperationType.createCategory &&
            operation.entityId == categoryId,
      );

      if (!hasPendingCreate) {
        final bool hasPendingDelete = queue.any(
          (PendingSyncOperation operation) =>
              operation.type == PendingSyncOperationType.deleteCategory &&
              operation.entityId == categoryId,
        );
        if (!hasPendingDelete) {
          queue.add(
            PendingSyncOperation(
              id: _generateOperationId(),
              type: PendingSyncOperationType.deleteCategory,
              entityId: categoryId,
              payload: <String, dynamic>{},
              createdAt: DateTime.now(),
            ),
          );
        }
      }
    }

    await _writeCategories(prefs, cachedCategories);
    await _writeQueue(prefs, queue);
  }

  @override
  Future<List<PendingSyncOperation>> getPendingOperations() async {
    final SharedPreferences prefs = await _resolvePreferences();
    final List<Map<String, dynamic>> rawList =
        await _readJsonList(prefs, await _queueKey(prefs));

    final List<PendingSyncOperation> queue = <PendingSyncOperation>[];
    for (final Map<String, dynamic> item in rawList) {
      try {
        final PendingSyncOperation operation =
            PendingSyncOperation.fromJson(item);
        if (operation.id.isNotEmpty && operation.entityId.isNotEmpty) {
          queue.add(operation);
        }
      } catch (_) {
        // Ignore malformed items.
      }
    }

    return queue;
  }

  @override
  Future<void> savePendingOperations(
    List<PendingSyncOperation> operations,
  ) async {
    final SharedPreferences prefs = await _resolvePreferences();
    await _writeQueue(prefs, operations);
  }

  @override
  Future<void> upsertExpense(ExpenseModel expense) async {
    final SharedPreferences prefs = await _resolvePreferences();
    final List<ExpenseModel> cachedExpenses = await getCachedExpenses();
    _upsertExpenseInList(cachedExpenses, expense);
    await _writeExpenses(prefs, cachedExpenses);
  }

  @override
  Future<void> upsertCategory(CategoryModel category) async {
    final SharedPreferences prefs = await _resolvePreferences();
    final List<CategoryModel> cachedCategories = await getCachedCategories();
    _upsertCategoryInList(cachedCategories, category);
    await _writeCategories(prefs, cachedCategories);
  }

  @override
  Future<void> removeExpense(String expenseId) async {
    final SharedPreferences prefs = await _resolvePreferences();
    final List<ExpenseModel> cachedExpenses = await getCachedExpenses();
    cachedExpenses
        .removeWhere((ExpenseModel expense) => expense.id == expenseId);
    await _writeExpenses(prefs, cachedExpenses);
  }

  @override
  Future<void> replaceExpenseIdAcrossStorage({
    required String fromId,
    required String toId,
  }) async {
    if (fromId == toId) {
      return;
    }

    final SharedPreferences prefs = await _resolvePreferences();
    final List<ExpenseModel> cachedExpenses = await getCachedExpenses();
    final List<PendingSyncOperation> queue = await getPendingOperations();

    for (int index = 0; index < cachedExpenses.length; index++) {
      final ExpenseModel expense = cachedExpenses[index];
      if (expense.id == fromId) {
        cachedExpenses[index] = ExpenseModel(
          id: toId,
          title: expense.title,
          amount: expense.amount,
          date: expense.date,
          categoryId: expense.categoryId,
          currencyCode: expense.currencyCode,
          fxRateSnapshot: expense.fxRateSnapshot,
          originalAmount: expense.originalAmount,
          location: expense.location,
          notes: expense.notes,
        );
      }
    }

    for (int index = 0; index < queue.length; index++) {
      final PendingSyncOperation operation = queue[index];
      if (operation.entityId == fromId) {
        queue[index] = operation.copyWith(entityId: toId);
      }
    }

    await _writeExpenses(prefs, cachedExpenses);
    await _writeQueue(prefs, queue);
  }

  @override
  Future<void> replaceCategoryIdAcrossStorage({
    required String fromId,
    required String toId,
  }) async {
    if (fromId == toId) {
      return;
    }

    final SharedPreferences prefs = await _resolvePreferences();
    final List<CategoryModel> cachedCategories = await getCachedCategories();
    final List<ExpenseModel> cachedExpenses = await getCachedExpenses();
    final List<PendingSyncOperation> queue = await getPendingOperations();

    for (int index = 0; index < cachedCategories.length; index++) {
      final CategoryModel category = cachedCategories[index];
      if (category.id == fromId) {
        cachedCategories[index] = CategoryModel(
          id: toId,
          name: category.name,
          color: category.color,
          icon: category.icon,
        );
      }
    }

    _deduplicateCategoriesById(cachedCategories);

    for (int index = 0; index < cachedExpenses.length; index++) {
      final ExpenseModel expense = cachedExpenses[index];
      if (expense.categoryId == fromId) {
        cachedExpenses[index] = ExpenseModel(
          id: expense.id,
          title: expense.title,
          amount: expense.amount,
          date: expense.date,
          categoryId: toId,
          currencyCode: expense.currencyCode,
          fxRateSnapshot: expense.fxRateSnapshot,
          originalAmount: expense.originalAmount,
          location: expense.location,
          notes: expense.notes,
        );
      }
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
        final String? payloadCategoryId =
            operation.payload['categoryId'] as String?;
        if (payloadCategoryId == fromId) {
          queue[index] = operation.copyWith(
            payload: <String, dynamic>{
              ...operation.payload,
              'categoryId': toId,
            },
          );
          continue;
        }
      }

      queue[index] = operation;
    }

    await _writeCategories(prefs, cachedCategories);
    await _writeExpenses(prefs, cachedExpenses);
    await _writeQueue(prefs, queue);
  }

  @override
  Future<void> migrateGuestDataToUser(String authenticatedUsername) async {
    final String encoded = Uri.encodeComponent(authenticatedUsername.trim());
    if (encoded.isEmpty) return;

    final SharedPreferences prefs = await _resolvePreferences();

    const String guestSuffix = 'guest';
    final String guestQueueKey = '$_storageNamespace.queue.$guestSuffix';
    final String guestExpenseKey = '$_storageNamespace.expenses.$guestSuffix';
    final String guestCategoryKey =
        '$_storageNamespace.categories.$guestSuffix';

    final List<Map<String, dynamic>> guestQueueRaw =
        await _readJsonList(prefs, guestQueueKey);
    final List<Map<String, dynamic>> guestExpensesRaw =
        await _readJsonList(prefs, guestExpenseKey);
    final List<Map<String, dynamic>> guestCategoriesRaw =
        await _readJsonList(prefs, guestCategoryKey);

    if (guestQueueRaw.isEmpty &&
        guestExpensesRaw.isEmpty &&
        guestCategoriesRaw.isEmpty) {
      return;
    }

    final String userQueueKey = '$_storageNamespace.queue.$encoded';
    final String userExpenseKey = '$_storageNamespace.expenses.$encoded';
    final String userCategoryKey = '$_storageNamespace.categories.$encoded';

    final List<Map<String, dynamic>> userQueueRaw =
        await _readJsonList(prefs, userQueueKey);
    final List<Map<String, dynamic>> userExpensesRaw =
        await _readJsonList(prefs, userExpenseKey);
    final List<Map<String, dynamic>> userCategoriesRaw =
        await _readJsonList(prefs, userCategoryKey);

    // Guest ops go first so they are synced before any existing user ops.
    final List<Map<String, dynamic>> mergedQueue = <Map<String, dynamic>>[
      ...guestQueueRaw,
      ...userQueueRaw,
    ];

    // Guest expenses prepended; deduplicate by id.
    final Map<String, Map<String, dynamic>> expenseMap =
        <String, Map<String, dynamic>>{};
    for (final Map<String, dynamic> item in <Map<String, dynamic>>[
      ...guestExpensesRaw,
      ...userExpensesRaw,
    ]) {
      final String? id = item['id'] as String?;
      if (id != null) expenseMap[id] = item;
    }

    // Guest categories prepended; deduplicate by id.
    final Map<String, Map<String, dynamic>> categoryMap =
        <String, Map<String, dynamic>>{};
    for (final Map<String, dynamic> item in <Map<String, dynamic>>[
      ...guestCategoriesRaw,
      ...userCategoriesRaw,
    ]) {
      final String? id = item['id'] as String?;
      if (id != null) categoryMap[id] = item;
    }

    await _writeJsonList(prefs, userQueueKey, mergedQueue);
    await _writeJsonList(
        prefs, userExpenseKey, expenseMap.values.toList());
    await _writeJsonList(
        prefs, userCategoryKey, categoryMap.values.toList());

    // Clear guest namespace.
    await prefs.remove(guestQueueKey);
    await prefs.remove(guestExpenseKey);
    await prefs.remove(guestCategoryKey);
  }

  @override
  Future<void> clearLocalCache() async {
    final SharedPreferences prefs = await _resolvePreferences();
    await prefs.remove(await _expenseKey(prefs));
    await prefs.remove(await _categoryKey(prefs));
  }

  @override
  Future<void> seedOfflineDefaultCategories() async {
    final SharedPreferences prefs = await _resolvePreferences();
    final List<CategoryModel> cached = await getCachedCategories();

    // If any server-origin category exists (ID without the offline prefix),
    // the server data is authoritative — do not seed offline defaults.
    final bool hasServerCategories = cached.any(
      (CategoryModel c) =>
          !c.id.startsWith(ExpenseLocalDataSource.offlineDefaultPrefix),
    );
    if (hasServerCategories) return;

    final Set<String> existingIds =
        cached.map((CategoryModel c) => c.id).toSet();

    bool changed = false;
    for (final Map<String, String> seed
        in ExpenseLocalDataSource.offlineDefaultSeeds) {
      if (!existingIds.contains(seed['id']!)) {
        cached.add(CategoryModel(
          id: seed['id']!,
          name: seed['name']!,
          icon: seed['icon']!,
          color: seed['color']!,
        ));
        changed = true;
      }
    }

    if (changed) {
      await _writeCategories(prefs, cached);
    }
  }

  Future<SharedPreferences> _resolvePreferences() async {
    return _preferences ?? SharedPreferences.getInstance();
  }

  Future<String> _expenseKey(SharedPreferences prefs) async {
    return _buildKey('expenses', prefs);
  }

  Future<String> _categoryKey(SharedPreferences prefs) async {
    return _buildKey('categories', prefs);
  }

  Future<String> _queueKey(SharedPreferences prefs) async {
    return _buildKey('queue', prefs);
  }

  Future<String> _buildKey(String scope, SharedPreferences prefs) async {
    final String username =
        (prefs.getString(AppStorageKeys.sessionUsername) ?? '').trim();
    final String scopedUser =
        username.isEmpty ? 'guest' : Uri.encodeComponent(username);
    return '$_storageNamespace.$scope.$scopedUser';
  }

  Future<List<Map<String, dynamic>>> _readJsonList(
    SharedPreferences prefs,
    String key,
  ) async {
    final String rawValue = (prefs.getString(key) ?? '').trim();
    if (rawValue.isEmpty) {
      return <Map<String, dynamic>>[];
    }

    try {
      final dynamic decoded = jsonDecode(rawValue);
      if (decoded is! List<dynamic>) {
        return <Map<String, dynamic>>[];
      }

      return decoded
          .whereType<Map<dynamic, dynamic>>()
          .map(
            (Map<dynamic, dynamic> item) =>
                item.map((key, value) => MapEntry(key.toString(), value)),
          )
          .toList(growable: false);
    } catch (_) {
      return <Map<String, dynamic>>[];
    }
  }

  Future<void> _writeJsonList(
    SharedPreferences prefs,
    String key,
    List<Map<String, dynamic>> value,
  ) async {
    await prefs.setString(key, jsonEncode(value));
  }

  Future<void> _writeExpenses(
    SharedPreferences prefs,
    List<ExpenseModel> expenses,
  ) async {
    await _writeJsonList(
      prefs,
      await _expenseKey(prefs),
      expenses.map((ExpenseModel expense) => expense.toJson()).toList(),
    );
  }

  Future<void> _writeCategories(
    SharedPreferences prefs,
    List<CategoryModel> categories,
  ) async {
    await _writeJsonList(
      prefs,
      await _categoryKey(prefs),
      categories.map((CategoryModel category) => category.toJson()).toList(),
    );
  }

  Future<void> _writeQueue(
    SharedPreferences prefs,
    List<PendingSyncOperation> queue,
  ) async {
    await _writeJsonList(
      prefs,
      await _queueKey(prefs),
      queue
          .map((PendingSyncOperation operation) => operation.toJson())
          .toList(),
    );
  }

  String _generateLocalId(String entity) {
    return 'local.$entity.${DateTime.now().microsecondsSinceEpoch}.${_random.nextInt(1 << 32)}';
  }

  String _generateOperationId() {
    return 'op.${DateTime.now().microsecondsSinceEpoch}.${_random.nextInt(1 << 32)}';
  }

  ExpenseModel _expenseFromDraft({
    required String expenseId,
    required ExpenseDraft draft,
  }) {
    final String currencyCode = draft.currencyCode.trim().toUpperCase();
    final double rate = currencyCode == 'VND' ? 1 / _usdToVnd : 1;
    final double amountInBase =
        double.parse((draft.amount * rate).toStringAsFixed(8));

    return ExpenseModel(
      id: expenseId,
      title: draft.title,
      amount: amountInBase,
      date: DateTime(draft.date.year, draft.date.month, draft.date.day),
      categoryId: draft.categoryId,
      currencyCode: currencyCode,
      fxRateSnapshot: rate,
      originalAmount: draft.amount,
      location: draft.location,
      notes: draft.notes,
    );
  }

  void _upsertExpenseInList(List<ExpenseModel> expenses, ExpenseModel next) {
    final int index =
        expenses.indexWhere((ExpenseModel item) => item.id == next.id);
    if (index >= 0) {
      expenses[index] = next;
      return;
    }
    expenses.insert(0, next);
  }

  void _upsertCategoryInList(
      List<CategoryModel> categories, CategoryModel next) {
    final int index =
        categories.indexWhere((CategoryModel item) => item.id == next.id);
    if (index >= 0) {
      categories[index] = next;
      return;
    }

    categories.add(next);
    categories.sort((CategoryModel first, CategoryModel second) {
      return first.name.compareTo(second.name);
    });
  }

  CategoryModel? _findCategoryByName(
    List<CategoryModel> categories,
    String name,
  ) {
    final String normalized = name.trim().toLowerCase();
    if (normalized.isEmpty) {
      return null;
    }

    for (final CategoryModel category in categories) {
      if (category.name.trim().toLowerCase() == normalized) {
        return category;
      }
    }

    return null;
  }

  void _deduplicateCategoriesById(List<CategoryModel> categories) {
    final Set<String> seen = <String>{};
    categories.removeWhere((CategoryModel category) {
      if (seen.contains(category.id)) {
        return true;
      }
      seen.add(category.id);
      return false;
    });
  }
}
