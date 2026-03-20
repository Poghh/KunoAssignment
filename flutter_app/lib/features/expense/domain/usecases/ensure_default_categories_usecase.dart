import 'package:shared_preferences/shared_preferences.dart';

import '../entities/category.dart';
import '../entities/default_category_seed.dart';
import '../repositories/expense_repository.dart';

class EnsureDefaultCategoriesUseCase {
  const EnsureDefaultCategoriesUseCase(this._repository, this._preferences);

  final ExpenseRepository _repository;
  final SharedPreferences _preferences;
  static Future<List<Category>>? _inFlightRequest;
  static const String _seededOncePrefix =
      'expense.default_categories_seeded_once';
  static const String _sessionUsernameStorageKey = 'session.username';

  Future<List<Category>> call() async {
    final Future<List<Category>>? currentRequest = _inFlightRequest;
    if (currentRequest != null) {
      return currentRequest;
    }

    final Future<List<Category>> nextRequest = _seedIfNeeded();
    _inFlightRequest = nextRequest;
    return nextRequest.whenComplete(() {
      if (identical(_inFlightRequest, nextRequest)) {
        _inFlightRequest = null;
      }
    });
  }

  Future<List<Category>> _seedIfNeeded() async {
    final List<Category> current = await _repository.getCategories();
    if (current.isNotEmpty) {
      await _markSeededOnceForCurrentUser();
      return current;
    }

    final bool hasSeededOnce = _isSeededOnceForCurrentUser();
    if (hasSeededOnce) {
      return current;
    }

    for (final Map<String, String> seed in kDefaultCategorySeeds) {
      final String name = (seed[kDefaultCategoryKeyName] ?? '').trim();
      final String icon = (seed[kDefaultCategoryKeyIcon] ?? '').trim();
      final String color = (seed[kDefaultCategoryKeyColor] ?? '').trim();
      if (name.isEmpty || icon.isEmpty) {
        continue;
      }

      try {
        await _repository.createCategory(
          name: name,
          icon: icon,
          color: color.isEmpty ? null : color,
        );
      } catch (_) {
        // Ignore conflicts/race conditions; fetch final state below.
      }
    }

    final List<Category> seeded = await _repository.getCategories();
    if (seeded.isNotEmpty) {
      await _markSeededOnceForCurrentUser();
    }

    return seeded;
  }

  bool _isSeededOnceForCurrentUser() {
    return _preferences.getBool(_seededOnceKeyForCurrentUser()) ?? false;
  }

  Future<void> _markSeededOnceForCurrentUser() {
    return _preferences.setBool(_seededOnceKeyForCurrentUser(), true);
  }

  String _seededOnceKeyForCurrentUser() {
    final String username =
        (_preferences.getString(_sessionUsernameStorageKey) ?? '').trim();
    final String scopedUser =
        username.isEmpty ? 'guest' : Uri.encodeComponent(username);
    return '$_seededOncePrefix.$scopedUser';
  }
}
