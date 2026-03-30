import 'package:shared_preferences/shared_preferences.dart';
import 'package:get_it/get_it.dart';

import '../../features/expense/data/datasources/expense_local_data_source.dart';
import '../../features/expense/data/datasources/expense_remote_data_source.dart';
import '../../features/expense/data/repositories/expense_repository_impl.dart';
import '../../features/expense/domain/repositories/expense_repository.dart';
import '../../features/expense/domain/usecases/create_category_usecase.dart';
import '../../features/expense/domain/usecases/delete_category_usecase.dart';
import '../../features/expense/domain/usecases/delete_expense_usecase.dart';
import '../../features/expense/domain/usecases/ensure_default_categories_usecase.dart';
import '../../features/expense/domain/usecases/get_dashboard_insights_usecase.dart';
import '../../features/expense/domain/usecases/get_expenses_usecase.dart';
import '../../features/expense/domain/usecases/save_expense_usecase.dart';
import '../../features/expense/presentation/cubit/category_management_cubit.dart';
import '../../features/expense/presentation/cubit/dashboard_cubit.dart';
import '../../features/expense/presentation/cubit/expense_form_cubit.dart';
import '../../features/expense/presentation/cubit/expense_list_cubit.dart';
import '../constants/app_network_constants.dart';
import '../network/api_client.dart';
import '../services/exchange_rate_service.dart';

final GetIt getIt = GetIt.instance;

Future<void> configureDependencies() async {
  final SharedPreferences preferences = await SharedPreferences.getInstance();
  await ExchangeRateService.initialize(preferences);
  getIt.registerLazySingleton<ApiClient>(createApiClient);
  getIt.registerLazySingleton<ExpenseLocalDataSource>(
    () => ExpenseLocalDataSourceImpl(preferences: preferences),
  );
  getIt.registerLazySingleton<ExpenseRemoteDataSource>(
    () => ExpenseRemoteDataSourceImpl(apiClient: getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<ExpenseRepository>(
    () => ExpenseRepositoryImpl(
      remoteDataSource: getIt<ExpenseRemoteDataSource>(),
      localDataSource: getIt<ExpenseLocalDataSource>(),
      isGuestMode: () =>
          preferences.getBool(AppStorageKeys.sessionGuestMode) ?? false,
    ),
  );
  getIt.registerLazySingleton<GetExpensesUseCase>(
    () => GetExpensesUseCase(getIt<ExpenseRepository>()),
  );
  getIt.registerLazySingleton<GetDashboardInsightsUseCase>(
    () => GetDashboardInsightsUseCase(getIt<ExpenseRepository>()),
  );
  getIt.registerLazySingleton<SaveExpenseUseCase>(
    () => SaveExpenseUseCase(getIt<ExpenseRepository>()),
  );
  getIt.registerLazySingleton<DeleteExpenseUseCase>(
    () => DeleteExpenseUseCase(getIt<ExpenseRepository>()),
  );
  getIt.registerLazySingleton<CreateCategoryUseCase>(
    () => CreateCategoryUseCase(getIt<ExpenseRepository>()),
  );
  getIt.registerLazySingleton<DeleteCategoryUseCase>(
    () => DeleteCategoryUseCase(getIt<ExpenseRepository>()),
  );
  getIt.registerLazySingleton<EnsureDefaultCategoriesUseCase>(
    () => EnsureDefaultCategoriesUseCase(
      getIt<ExpenseRepository>(),
      preferences,
    ),
  );

  getIt.registerFactory<DashboardCubit>(
    () => DashboardCubit(
      getExpensesUseCase: getIt<GetExpensesUseCase>(),
      ensureDefaultCategoriesUseCase: getIt<EnsureDefaultCategoriesUseCase>(),
      getDashboardInsightsUseCase: getIt<GetDashboardInsightsUseCase>(),
    ),
  );
  getIt.registerFactory<ExpenseListCubit>(
    () => ExpenseListCubit(
      getExpensesUseCase: getIt<GetExpensesUseCase>(),
      ensureDefaultCategoriesUseCase: getIt<EnsureDefaultCategoriesUseCase>(),
      deleteExpenseUseCase: getIt<DeleteExpenseUseCase>(),
    ),
  );
  getIt.registerFactory<ExpenseFormCubit>(
    () => ExpenseFormCubit(
      ensureDefaultCategoriesUseCase: getIt<EnsureDefaultCategoriesUseCase>(),
      saveExpenseUseCase: getIt<SaveExpenseUseCase>(),
      createCategoryUseCase: getIt<CreateCategoryUseCase>(),
      deleteCategoryUseCase: getIt<DeleteCategoryUseCase>(),
    ),
  );
  getIt.registerFactory<CategoryManagementCubit>(
    () => CategoryManagementCubit(
      ensureDefaultCategoriesUseCase: getIt<EnsureDefaultCategoriesUseCase>(),
      createCategoryUseCase: getIt<CreateCategoryUseCase>(),
      deleteCategoryUseCase: getIt<DeleteCategoryUseCase>(),
      getExpensesUseCase: getIt<GetExpensesUseCase>(),
    ),
  );
}
