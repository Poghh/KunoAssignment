import '../entities/category.dart';
import '../repositories/expense_repository.dart';

class GetCategoriesUseCase {
  const GetCategoriesUseCase(this._repository);

  final ExpenseRepository _repository;

  Future<List<Category>> call() {
    return _repository.getCategories();
  }
}
