import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:expense_tracker_app/features/expense/domain/entities/category.dart';
import 'package:expense_tracker_app/features/expense/domain/entities/expense.dart';
import 'package:expense_tracker_app/features/expense/domain/usecases/delete_expense_usecase.dart';
import 'package:expense_tracker_app/features/expense/domain/usecases/ensure_default_categories_usecase.dart';
import 'package:expense_tracker_app/features/expense/domain/usecases/get_expenses_usecase.dart';
import 'package:expense_tracker_app/features/expense/presentation/cubit/expense_list_cubit.dart';
import 'package:expense_tracker_app/features/expense/presentation/cubit/expense_list_state.dart';

class MockGetExpensesUseCase extends Mock implements GetExpensesUseCase {}

class MockEnsureDefaultCategoriesUseCase extends Mock
    implements EnsureDefaultCategoriesUseCase {}

class MockDeleteExpenseUseCase extends Mock implements DeleteExpenseUseCase {}

final _category = const Category(
  id: 'cat-1',
  name: 'Food',
  color: '#EF5350',
  icon: 'restaurant',
);

Expense _expense({
  required String id,
  required DateTime date,
  double amount = 10.0,
}) =>
    Expense(
      id: id,
      title: 'Test $id',
      amount: amount,
      date: date,
      categoryId: 'cat-1',
    );

void main() {
  late MockGetExpensesUseCase mockGetExpenses;
  late MockEnsureDefaultCategoriesUseCase mockEnsureCategories;
  late MockDeleteExpenseUseCase mockDeleteExpense;

  setUp(() {
    mockGetExpenses = MockGetExpensesUseCase();
    mockEnsureCategories = MockEnsureDefaultCategoriesUseCase();
    mockDeleteExpense = MockDeleteExpenseUseCase();
  });

  ExpenseListCubit buildCubit() => ExpenseListCubit(
        getExpensesUseCase: mockGetExpenses,
        ensureDefaultCategoriesUseCase: mockEnsureCategories,
        deleteExpenseUseCase: mockDeleteExpense,
      );

  group('ExpenseListCubit', () {
    group('loadExpenses', () {
      final expenses = <Expense>[
        _expense(id: 'e1', date: DateTime(2024, 1, 10)),
        _expense(id: 'e2', date: DateTime(2024, 1, 5)),
      ];

      blocTest<ExpenseListCubit, ExpenseListState>(
        'emits loading then success with expenses and categories',
        setUp: () {
          when(() => mockGetExpenses()).thenAnswer((_) async => expenses);
          when(() => mockEnsureCategories())
              .thenAnswer((_) async => [_category]);
        },
        build: buildCubit,
        act: (cubit) => cubit.loadExpenses(),
        expect: () => [
          const ExpenseListState(status: ExpenseListStatus.loading),
          isA<ExpenseListState>()
              .having((s) => s.status, 'status', ExpenseListStatus.success)
              .having((s) => s.allExpenses.length, 'expense count', 2)
              .having((s) => s.categories.length, 'category count', 1),
        ],
      );

      blocTest<ExpenseListCubit, ExpenseListState>(
        'sorts expenses latest first by default',
        setUp: () {
          when(() => mockGetExpenses()).thenAnswer((_) async => [
                _expense(id: 'old', date: DateTime(2024, 1, 1)),
                _expense(id: 'new', date: DateTime(2024, 3, 1)),
                _expense(id: 'mid', date: DateTime(2024, 2, 1)),
              ]);
          when(() => mockEnsureCategories()).thenAnswer((_) async => []);
        },
        build: buildCubit,
        act: (cubit) => cubit.loadExpenses(),
        verify: (cubit) {
          expect(cubit.state.filteredExpenses.first.id, 'new');
          expect(cubit.state.filteredExpenses.last.id, 'old');
        },
      );

      blocTest<ExpenseListCubit, ExpenseListState>(
        'emits failure when getExpenses throws',
        setUp: () {
          when(() => mockGetExpenses()).thenThrow(Exception('Network error'));
          when(() => mockEnsureCategories()).thenAnswer((_) async => []);
        },
        build: buildCubit,
        act: (cubit) => cubit.loadExpenses(),
        expect: () => [
          const ExpenseListState(status: ExpenseListStatus.loading),
          isA<ExpenseListState>()
              .having((s) => s.status, 'status', ExpenseListStatus.failure),
        ],
      );

      blocTest<ExpenseListCubit, ExpenseListState>(
        'does not emit loading when showLoading is false',
        setUp: () {
          when(() => mockGetExpenses()).thenAnswer((_) async => []);
          when(() => mockEnsureCategories()).thenAnswer((_) async => []);
        },
        build: buildCubit,
        act: (cubit) => cubit.loadExpenses(showLoading: false),
        expect: () => [
          isA<ExpenseListState>()
              .having((s) => s.status, 'status', ExpenseListStatus.success),
        ],
      );
    });

    group('setCategoryFilter', () {
      final expenses = <Expense>[
        _expense(id: 'e1', date: DateTime(2024, 1, 10)),
        Expense(
          id: 'e2',
          title: 'e2',
          amount: 5,
          date: DateTime(2024, 1, 5),
          categoryId: 'cat-other',
        ),
      ];

      blocTest<ExpenseListCubit, ExpenseListState>(
        'filters expenses to selected category',
        setUp: () {
          when(() => mockGetExpenses()).thenAnswer((_) async => expenses);
          when(() => mockEnsureCategories()).thenAnswer((_) async => []);
        },
        build: buildCubit,
        act: (cubit) async {
          await cubit.loadExpenses();
          cubit.setCategoryFilter('cat-1');
        },
        verify: (cubit) {
          expect(cubit.state.filteredExpenses.length, 1);
          expect(cubit.state.filteredExpenses.first.id, 'e1');
        },
      );

      blocTest<ExpenseListCubit, ExpenseListState>(
        'clearFilters shows all expenses again',
        setUp: () {
          when(() => mockGetExpenses()).thenAnswer((_) async => expenses);
          when(() => mockEnsureCategories()).thenAnswer((_) async => []);
        },
        build: buildCubit,
        act: (cubit) async {
          await cubit.loadExpenses();
          cubit.setCategoryFilter('cat-1');
          cubit.clearFilters();
        },
        verify: (cubit) {
          expect(cubit.state.filteredExpenses.length, 2);
          expect(cubit.state.selectedCategoryId, isNull);
        },
      );
    });

    group('setSortOption', () {
      final expenses = <Expense>[
        _expense(id: 'cheap', date: DateTime(2024, 1, 1), amount: 5),
        _expense(id: 'expensive', date: DateTime(2024, 1, 2), amount: 100),
        _expense(id: 'mid', date: DateTime(2024, 1, 3), amount: 50),
      ];

      blocTest<ExpenseListCubit, ExpenseListState>(
        'sorts by amount high to low',
        setUp: () {
          when(() => mockGetExpenses()).thenAnswer((_) async => expenses);
          when(() => mockEnsureCategories()).thenAnswer((_) async => []);
        },
        build: buildCubit,
        act: (cubit) async {
          await cubit.loadExpenses();
          cubit.setSortOption(ExpenseSortOption.amountHigh);
        },
        verify: (cubit) {
          expect(cubit.state.filteredExpenses.first.id, 'expensive');
          expect(cubit.state.filteredExpenses.last.id, 'cheap');
        },
      );

      blocTest<ExpenseListCubit, ExpenseListState>(
        'sorts by oldest first',
        setUp: () {
          when(() => mockGetExpenses()).thenAnswer((_) async => expenses);
          when(() => mockEnsureCategories()).thenAnswer((_) async => []);
        },
        build: buildCubit,
        act: (cubit) async {
          await cubit.loadExpenses();
          cubit.setSortOption(ExpenseSortOption.oldest);
        },
        verify: (cubit) {
          expect(cubit.state.filteredExpenses.first.id, 'cheap');
          expect(cubit.state.filteredExpenses.last.id, 'mid');
        },
      );

      blocTest<ExpenseListCubit, ExpenseListState>(
        'sorts same-day expenses in reverse order for oldest first',
        setUp: () {
          when(() => mockGetExpenses()).thenAnswer((_) async => [
                _expense(id: 'first', date: DateTime(2024, 1, 1)),
                _expense(id: 'second', date: DateTime(2024, 1, 1)),
                _expense(id: 'third', date: DateTime(2024, 1, 1)),
              ]);
          when(() => mockEnsureCategories()).thenAnswer((_) async => []);
        },
        build: buildCubit,
        act: (cubit) async {
          await cubit.loadExpenses();
          cubit.setSortOption(ExpenseSortOption.oldest);
        },
        verify: (cubit) {
          expect(
            cubit.state.filteredExpenses.map((Expense expense) => expense.id),
            <String>['third', 'second', 'first'],
          );
        },
      );
    });

    group('setDateRangeFilter', () {
      final expenses = <Expense>[
        _expense(id: 'jan', date: DateTime(2024, 1, 15)),
        _expense(id: 'feb', date: DateTime(2024, 2, 15)),
        _expense(id: 'mar', date: DateTime(2024, 3, 15)),
      ];

      blocTest<ExpenseListCubit, ExpenseListState>(
        'filters to date range',
        setUp: () {
          when(() => mockGetExpenses()).thenAnswer((_) async => expenses);
          when(() => mockEnsureCategories()).thenAnswer((_) async => []);
        },
        build: buildCubit,
        act: (cubit) async {
          await cubit.loadExpenses();
          cubit.setDateRangeFilter(DateTimeRange(
            start: DateTime(2024, 1, 1),
            end: DateTime(2024, 2, 28),
          ));
        },
        verify: (cubit) {
          expect(cubit.state.filteredExpenses.length, 2);
        },
      );
    });

    group('deleteExpense', () {
      final expenses = <Expense>[
        _expense(id: 'e1', date: DateTime(2024, 1, 10)),
        _expense(id: 'e2', date: DateTime(2024, 1, 5)),
      ];

      blocTest<ExpenseListCubit, ExpenseListState>(
        'removes expense from list on success',
        setUp: () {
          when(() => mockGetExpenses()).thenAnswer((_) async => expenses);
          when(() => mockEnsureCategories()).thenAnswer((_) async => []);
          when(() => mockDeleteExpense('e1')).thenAnswer((_) async {});
        },
        build: buildCubit,
        act: (cubit) async {
          await cubit.loadExpenses();
          await cubit.deleteExpense('e1');
        },
        verify: (cubit) {
          expect(cubit.state.allExpenses.length, 1);
          expect(cubit.state.allExpenses.first.id, 'e2');
        },
      );

      blocTest<ExpenseListCubit, ExpenseListState>(
        'emits failure state when delete throws',
        setUp: () {
          when(() => mockGetExpenses()).thenAnswer((_) async => expenses);
          when(() => mockEnsureCategories()).thenAnswer((_) async => []);
          when(() => mockDeleteExpense('e1'))
              .thenThrow(Exception('Delete failed'));
        },
        build: buildCubit,
        act: (cubit) async {
          await cubit.loadExpenses();
          await cubit.deleteExpense('e1');
        },
        verify: (cubit) {
          expect(cubit.state.status, ExpenseListStatus.failure);
        },
      );
    });
  });
}
