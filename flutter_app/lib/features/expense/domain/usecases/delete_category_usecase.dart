import '../repositories/expense_repository.dart';

class DeleteCategoryUseCase {
  const DeleteCategoryUseCase(this._repository);

  final ExpenseRepository _repository;

  Future<void> call(String categoryId) {
    return _repository.deleteCategory(categoryId);
  }
}
