import 'package:equatable/equatable.dart';

import '../../domain/entities/category.dart';

enum ExpenseFormStatus {
  initial,
  loadingCategories,
  ready,
  submitting,
  success,
  failure,
}

class ExpenseFormState extends Equatable {
  const ExpenseFormState({
    this.status = ExpenseFormStatus.initial,
    this.categories = const <Category>[],
    this.isFormValid = false,
    this.errorMessage,
  });

  final ExpenseFormStatus status;
  final List<Category> categories;
  final bool isFormValid;
  final String? errorMessage;

  bool get isSubmitting => status == ExpenseFormStatus.submitting;

  static const Object _sentinel = Object();

  ExpenseFormState copyWith({
    ExpenseFormStatus? status,
    List<Category>? categories,
    bool? isFormValid,
    Object? errorMessage = _sentinel,
  }) {
    return ExpenseFormState(
      status: status ?? this.status,
      categories: categories ?? this.categories,
      isFormValid: isFormValid ?? this.isFormValid,
      errorMessage: identical(errorMessage, _sentinel)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  @override
  List<Object?> get props =>
      <Object?>[status, categories, isFormValid, errorMessage];
}
