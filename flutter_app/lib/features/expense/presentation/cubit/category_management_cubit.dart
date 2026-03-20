import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_network_constants.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/expense.dart';
import '../../domain/usecases/create_category_usecase.dart';
import '../../domain/usecases/delete_category_usecase.dart';
import '../../domain/usecases/ensure_default_categories_usecase.dart';
import '../../domain/usecases/get_expenses_usecase.dart';
import 'category_management_state.dart';

class CategoryManagementCubit extends Cubit<CategoryManagementState> {
  CategoryManagementCubit({
    required this.ensureDefaultCategoriesUseCase,
    required this.createCategoryUseCase,
    required this.deleteCategoryUseCase,
    required this.getExpensesUseCase,
  }) : super(const CategoryManagementState());

  final EnsureDefaultCategoriesUseCase ensureDefaultCategoriesUseCase;
  final CreateCategoryUseCase createCategoryUseCase;
  final DeleteCategoryUseCase deleteCategoryUseCase;
  final GetExpensesUseCase getExpensesUseCase;

  Future<void> load({bool showLoading = true}) async {
    if (showLoading) {
      emit(
        state.copyWith(
          status: CategoryManagementStatus.loading,
          errorMessage: null,
        ),
      );
    }

    try {
      final List<dynamic> response = await Future.wait<dynamic>(
        <Future<dynamic>>[
          ensureDefaultCategoriesUseCase(),
          getExpensesUseCase(),
        ],
      );

      final List<Category> categories =
          (response[0] as List<dynamic>).cast<Category>()
            ..sort((Category first, Category second) {
              return first.name.compareTo(second.name);
            });
      final List<Expense> expenses = (response[1] as List<Expense>);

      emit(
        state.copyWith(
          status: CategoryManagementStatus.success,
          categories: categories,
          expenseCountByCategory: _buildExpenseCountMap(expenses),
          errorMessage: null,
          isMutating: false,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: CategoryManagementStatus.failure,
          errorMessage: _resolveErrorMessage(error),
          isMutating: false,
        ),
      );
    }
  }

  Future<Category?> createCategory({
    required String name,
    required String icon,
    String? color,
  }) async {
    final String trimmedName = name.trim();
    if (trimmedName.length < 2) {
      return null;
    }

    emit(state.copyWith(isMutating: true, errorMessage: null));

    try {
      final Category created = await createCategoryUseCase(
        name: trimmedName,
        icon: icon,
        color: color,
      );

      final List<Category> nextCategories = <Category>[
        ...state.categories,
        created,
      ]..sort((Category first, Category second) {
          return first.name.compareTo(second.name);
        });

      final Map<String, int> nextCountMap = <String, int>{
        ...state.expenseCountByCategory,
        created.id: 0,
      };

      emit(
        state.copyWith(
          status: CategoryManagementStatus.success,
          categories: nextCategories,
          expenseCountByCategory: nextCountMap,
          errorMessage: null,
          isMutating: false,
        ),
      );
      return created;
    } catch (error) {
      emit(
        state.copyWith(
          status: CategoryManagementStatus.failure,
          errorMessage: _resolveErrorMessage(error),
          isMutating: false,
        ),
      );
      return null;
    }
  }

  Future<bool> deleteCategory(String categoryId) async {
    final String normalizedCategoryId = categoryId.trim();
    if (normalizedCategoryId.isEmpty) {
      return false;
    }

    emit(state.copyWith(isMutating: true, errorMessage: null));

    try {
      await deleteCategoryUseCase(normalizedCategoryId);

      final List<Category> nextCategories = state.categories
          .where((Category category) => category.id != normalizedCategoryId)
          .toList(growable: false);

      final Map<String, int> nextCountMap = Map<String, int>.from(
        state.expenseCountByCategory,
      )..remove(normalizedCategoryId);

      emit(
        state.copyWith(
          status: CategoryManagementStatus.success,
          categories: nextCategories,
          expenseCountByCategory: nextCountMap,
          errorMessage: null,
          isMutating: false,
        ),
      );
      return true;
    } catch (error) {
      emit(
        state.copyWith(
          status: CategoryManagementStatus.failure,
          errorMessage: _resolveErrorMessage(error),
          isMutating: false,
        ),
      );
      return false;
    }
  }

  Map<String, int> _buildExpenseCountMap(List<Expense> expenses) {
    final Map<String, int> map = <String, int>{};
    for (final Expense expense in expenses) {
      final String categoryId = expense.categoryId;
      if (categoryId.isEmpty) {
        continue;
      }
      map[categoryId] = (map[categoryId] ?? 0) + 1;
    }
    return map;
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

    final String rawMessage = error.toString().trim();
    if (rawMessage.startsWith('Bad state:')) {
      return rawMessage.replaceFirst('Bad state:', '').trim();
    }
    if (rawMessage.startsWith('Exception:')) {
      return rawMessage.replaceFirst('Exception:', '').trim();
    }

    return AppApiErrorMessage.unknown;
  }
}
