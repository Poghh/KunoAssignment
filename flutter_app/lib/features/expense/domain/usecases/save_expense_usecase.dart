import '../entities/expense.dart';
import '../repositories/expense_repository.dart';

class SaveExpenseUseCase {
  const SaveExpenseUseCase(this._repository);

  final ExpenseRepository _repository;

  Future<void> call({
    String? expenseId,
    required ExpenseDraft draft,
  }) async {
    if (expenseId == null) {
      await _repository.createExpense(draft);
      return;
    }

    await _repository.updateExpense(expenseId: expenseId, draft: draft);
  }
}
