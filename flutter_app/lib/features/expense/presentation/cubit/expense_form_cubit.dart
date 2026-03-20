import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_network_constants.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/expense.dart';
import '../../domain/usecases/create_category_usecase.dart';
import '../../domain/usecases/delete_category_usecase.dart';
import '../../domain/usecases/ensure_default_categories_usecase.dart';
import '../../domain/usecases/save_expense_usecase.dart';
import 'expense_form_state.dart';

class ExpenseFormCubit extends Cubit<ExpenseFormState> {
  ExpenseFormCubit({
    required this.ensureDefaultCategoriesUseCase,
    required this.saveExpenseUseCase,
    required this.createCategoryUseCase,
    required this.deleteCategoryUseCase,
  }) : super(const ExpenseFormState());

  final EnsureDefaultCategoriesUseCase ensureDefaultCategoriesUseCase;
  final SaveExpenseUseCase saveExpenseUseCase;
  final CreateCategoryUseCase createCategoryUseCase;
  final DeleteCategoryUseCase deleteCategoryUseCase;

  Future<void> loadCategories({bool showLoading = true}) async {
    if (showLoading) {
      emit(
        state.copyWith(
          status: ExpenseFormStatus.loadingCategories,
          errorMessage: null,
        ),
      );
    }

    try {
      final List<Category> categories = await ensureDefaultCategoriesUseCase();
      emit(
        state.copyWith(
          status: ExpenseFormStatus.ready,
          categories: categories,
          errorMessage: null,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: ExpenseFormStatus.failure,
          errorMessage: _resolveErrorMessage(error),
        ),
      );
    }
  }

  void validateForm({
    required String title,
    required String amountText,
    required String? categoryId,
  }) {
    final double? amount = double.tryParse(amountText.trim());
    final bool isValid = title.trim().length >= 2 &&
        amount != null &&
        amount > 0 &&
        categoryId != null;

    if (state.isFormValid == isValid) {
      return;
    }

    emit(state.copyWith(isFormValid: isValid));
  }

  Future<bool> saveExpense({
    String? expenseId,
    required ExpenseDraft draft,
  }) async {
    emit(
      state.copyWith(
        status: ExpenseFormStatus.submitting,
        errorMessage: null,
      ),
    );

    try {
      await saveExpenseUseCase(expenseId: expenseId, draft: draft);
      emit(state.copyWith(status: ExpenseFormStatus.success));
      return true;
    } catch (error) {
      emit(
        state.copyWith(
          status: ExpenseFormStatus.failure,
          errorMessage: _resolveErrorMessage(error),
        ),
      );
      return false;
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

    try {
      final Category createdCategory = await createCategoryUseCase(
        name: trimmedName,
        icon: icon,
        color: color,
      );
      final List<Category> nextCategories = <Category>[
        ...state.categories,
        createdCategory,
      ]..sort((Category first, Category second) =>
          first.name.compareTo(second.name));

      emit(
        state.copyWith(
          categories: nextCategories,
          errorMessage: null,
        ),
      );
      return createdCategory;
    } catch (error) {
      emit(
        state.copyWith(
          status: ExpenseFormStatus.failure,
          errorMessage: _resolveErrorMessage(error),
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

    try {
      await deleteCategoryUseCase(normalizedCategoryId);
      final List<Category> nextCategories = state.categories
          .where((Category category) => category.id != normalizedCategoryId)
          .toList(growable: false);
      emit(
        state.copyWith(
          status: ExpenseFormStatus.ready,
          categories: nextCategories,
          errorMessage: null,
        ),
      );
      return true;
    } catch (error) {
      emit(
        state.copyWith(
          status: ExpenseFormStatus.failure,
          errorMessage: _resolveErrorMessage(error),
        ),
      );
      return false;
    }
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
