import '../entities/category.dart';
import '../repositories/expense_repository.dart';

class CreateCategoryUseCase {
  const CreateCategoryUseCase(this._repository);

  final ExpenseRepository _repository;

  Future<Category> call({
    required String name,
    required String icon,
    String? color,
  }) {
    return _repository.createCategory(name: name, icon: icon, color: color);
  }
}
