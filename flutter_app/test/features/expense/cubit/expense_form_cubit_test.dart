import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:expense_tracker_app/features/expense/domain/entities/category.dart';
import 'package:expense_tracker_app/features/expense/domain/entities/expense.dart';
import 'package:expense_tracker_app/features/expense/domain/usecases/create_category_usecase.dart';
import 'package:expense_tracker_app/features/expense/domain/usecases/delete_category_usecase.dart';
import 'package:expense_tracker_app/features/expense/domain/usecases/ensure_default_categories_usecase.dart';
import 'package:expense_tracker_app/features/expense/domain/usecases/save_expense_usecase.dart';
import 'package:expense_tracker_app/features/expense/presentation/cubit/expense_form_cubit.dart';
import 'package:expense_tracker_app/features/expense/presentation/cubit/expense_form_state.dart';

class MockEnsureDefaultCategoriesUseCase extends Mock
    implements EnsureDefaultCategoriesUseCase {}

class MockSaveExpenseUseCase extends Mock implements SaveExpenseUseCase {}

class MockCreateCategoryUseCase extends Mock implements CreateCategoryUseCase {}

class MockDeleteCategoryUseCase extends Mock implements DeleteCategoryUseCase {}

class FakeExpenseDraft extends Fake implements ExpenseDraft {}

final _category = const Category(
  id: 'cat-1',
  name: 'Food',
  color: '#EF5350',
  icon: 'restaurant',
);

void main() {
  late MockEnsureDefaultCategoriesUseCase mockEnsureCategories;
  late MockSaveExpenseUseCase mockSaveExpense;
  late MockCreateCategoryUseCase mockCreateCategory;
  late MockDeleteCategoryUseCase mockDeleteCategory;

  setUpAll(() {
    registerFallbackValue(FakeExpenseDraft());
  });

  setUp(() {
    mockEnsureCategories = MockEnsureDefaultCategoriesUseCase();
    mockSaveExpense = MockSaveExpenseUseCase();
    mockCreateCategory = MockCreateCategoryUseCase();
    mockDeleteCategory = MockDeleteCategoryUseCase();
  });

  ExpenseFormCubit buildCubit() => ExpenseFormCubit(
        ensureDefaultCategoriesUseCase: mockEnsureCategories,
        saveExpenseUseCase: mockSaveExpense,
        createCategoryUseCase: mockCreateCategory,
        deleteCategoryUseCase: mockDeleteCategory,
      );

  group('ExpenseFormCubit', () {
    group('loadCategories', () {
      blocTest<ExpenseFormCubit, ExpenseFormState>(
        'emits loadingCategories then ready with categories',
        setUp: () {
          when(() => mockEnsureCategories())
              .thenAnswer((_) async => [_category]);
        },
        build: buildCubit,
        act: (cubit) => cubit.loadCategories(),
        expect: () => [
          const ExpenseFormState(status: ExpenseFormStatus.loadingCategories),
          isA<ExpenseFormState>()
              .having((s) => s.status, 'status', ExpenseFormStatus.ready)
              .having((s) => s.categories.length, 'categories', 1),
        ],
      );

      blocTest<ExpenseFormCubit, ExpenseFormState>(
        'emits failure when categories cannot be loaded',
        setUp: () {
          when(() => mockEnsureCategories())
              .thenThrow(Exception('Network error'));
        },
        build: buildCubit,
        act: (cubit) => cubit.loadCategories(),
        expect: () => [
          const ExpenseFormState(status: ExpenseFormStatus.loadingCategories),
          isA<ExpenseFormState>()
              .having((s) => s.status, 'status', ExpenseFormStatus.failure),
        ],
      );
    });

    group('validateForm', () {
      test('isFormValid is true when all fields are valid', () {
        final cubit = buildCubit();
        cubit.validateForm(
          title: 'Lunch',
          amountText: '10.5',
          categoryId: 'cat-1',
        );
        expect(cubit.state.isFormValid, isTrue);
        cubit.close();
      });

      test('isFormValid is false when title is too short', () {
        final cubit = buildCubit();
        cubit.validateForm(
          title: 'A',
          amountText: '10.5',
          categoryId: 'cat-1',
        );
        expect(cubit.state.isFormValid, isFalse);
        cubit.close();
      });

      test('isFormValid is false when amount is zero', () {
        final cubit = buildCubit();
        cubit.validateForm(
          title: 'Lunch',
          amountText: '0',
          categoryId: 'cat-1',
        );
        expect(cubit.state.isFormValid, isFalse);
        cubit.close();
      });

      test('isFormValid is false when amount is not a number', () {
        final cubit = buildCubit();
        cubit.validateForm(
          title: 'Lunch',
          amountText: 'abc',
          categoryId: 'cat-1',
        );
        expect(cubit.state.isFormValid, isFalse);
        cubit.close();
      });

      test('isFormValid is false when category is null', () {
        final cubit = buildCubit();
        cubit.validateForm(
          title: 'Lunch',
          amountText: '10',
          categoryId: null,
        );
        expect(cubit.state.isFormValid, isFalse);
        cubit.close();
      });
    });

    group('saveExpense', () {
      final draft = ExpenseDraft(
        title: 'Lunch',
        amount: 10.0,
        date: DateTime(2024, 1, 1),
        categoryId: 'cat-1',
      );

      blocTest<ExpenseFormCubit, ExpenseFormState>(
        'emits submitting then success',
        setUp: () {
          when(() => mockSaveExpense(expenseId: any(named: 'expenseId'), draft: any(named: 'draft')))
              .thenAnswer((_) async {});
        },
        build: buildCubit,
        act: (cubit) => cubit.saveExpense(draft: draft),
        expect: () => [
          isA<ExpenseFormState>()
              .having((s) => s.status, 'status', ExpenseFormStatus.submitting),
          isA<ExpenseFormState>()
              .having((s) => s.status, 'status', ExpenseFormStatus.success),
        ],
      );

      blocTest<ExpenseFormCubit, ExpenseFormState>(
        'emits failure when save throws',
        setUp: () {
          when(() => mockSaveExpense(expenseId: any(named: 'expenseId'), draft: any(named: 'draft')))
              .thenThrow(Exception('Save failed'));
        },
        build: buildCubit,
        act: (cubit) => cubit.saveExpense(draft: draft),
        expect: () => [
          isA<ExpenseFormState>()
              .having((s) => s.status, 'status', ExpenseFormStatus.submitting),
          isA<ExpenseFormState>()
              .having((s) => s.status, 'status', ExpenseFormStatus.failure)
              .having((s) => s.errorMessage, 'errorMessage', isNotNull),
        ],
      );
    });

    group('createCategory', () {
      blocTest<ExpenseFormCubit, ExpenseFormState>(
        'returns null when name is too short',
        build: buildCubit,
        act: (cubit) => cubit.createCategory(name: 'A', icon: 'category'),
        verify: (cubit) {
          verifyNever(() => mockCreateCategory(
                name: any(named: 'name'),
                icon: any(named: 'icon'),
                color: any(named: 'color'),
              ));
        },
      );

      blocTest<ExpenseFormCubit, ExpenseFormState>(
        'adds new category to state on success',
        setUp: () {
          when(() => mockCreateCategory(
                name: any(named: 'name'),
                icon: any(named: 'icon'),
                color: any(named: 'color'),
              )).thenAnswer((_) async => _category);
        },
        build: buildCubit,
        act: (cubit) => cubit.createCategory(name: 'Food', icon: 'restaurant'),
        verify: (cubit) {
          expect(cubit.state.categories, contains(_category));
        },
      );
    });

    group('deleteCategory', () {
      blocTest<ExpenseFormCubit, ExpenseFormState>(
        'removes category from state on success',
        setUp: () {
          when(() => mockEnsureCategories())
              .thenAnswer((_) async => [_category]);
          when(() => mockDeleteCategory('cat-1')).thenAnswer((_) async {});
        },
        build: buildCubit,
        act: (cubit) async {
          await cubit.loadCategories();
          await cubit.deleteCategory('cat-1');
        },
        verify: (cubit) {
          expect(cubit.state.categories, isEmpty);
        },
      );
    });
  });
}
