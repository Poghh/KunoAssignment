import 'package:equatable/equatable.dart';

import '../../domain/entities/category.dart';

enum CategoryManagementStatus {
  initial,
  loading,
  success,
  failure,
}

class CategoryManagementState extends Equatable {
  const CategoryManagementState({
    this.status = CategoryManagementStatus.initial,
    this.categories = const <Category>[],
    this.expenseCountByCategory = const <String, int>{},
    this.errorMessage,
    this.isMutating = false,
  });

  final CategoryManagementStatus status;
  final List<Category> categories;
  final Map<String, int> expenseCountByCategory;
  final String? errorMessage;
  final bool isMutating;

  int expenseCountOf(String categoryId) {
    return expenseCountByCategory[categoryId] ?? 0;
  }

  bool canDeleteCategory(String categoryId) {
    return expenseCountOf(categoryId) == 0;
  }

  static const Object _sentinel = Object();

  CategoryManagementState copyWith({
    CategoryManagementStatus? status,
    List<Category>? categories,
    Map<String, int>? expenseCountByCategory,
    Object? errorMessage = _sentinel,
    bool? isMutating,
  }) {
    return CategoryManagementState(
      status: status ?? this.status,
      categories: categories ?? this.categories,
      expenseCountByCategory: expenseCountByCategory ?? this.expenseCountByCategory,
      errorMessage: identical(errorMessage, _sentinel)
          ? this.errorMessage
          : errorMessage as String?,
      isMutating: isMutating ?? this.isMutating,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        status,
        categories,
        expenseCountByCategory,
        errorMessage,
        isMutating,
      ];
}
