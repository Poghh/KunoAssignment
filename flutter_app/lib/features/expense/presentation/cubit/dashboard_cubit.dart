import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_network_constants.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/expense.dart';
import '../../domain/entities/insight.dart';
import '../../domain/usecases/ensure_default_categories_usecase.dart';
import '../../domain/usecases/get_dashboard_insights_usecase.dart';
import '../../domain/usecases/get_expenses_usecase.dart';
import 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit({
    required this.getExpensesUseCase,
    required this.ensureDefaultCategoriesUseCase,
    required this.getDashboardInsightsUseCase,
  }) : super(const DashboardState());

  final GetExpensesUseCase getExpensesUseCase;
  final EnsureDefaultCategoriesUseCase ensureDefaultCategoriesUseCase;
  final GetDashboardInsightsUseCase getDashboardInsightsUseCase;

  void reset() {
    emit(const DashboardState());
  }

  Future<void> loadDashboard({bool showLoading = true}) async {
    if (showLoading) {
      emit(
        state.copyWith(
          status: DashboardStatus.loading,
          errorMessage: null,
        ),
      );
    }

    try {
      final List<dynamic> response = await Future.wait<dynamic>(
        <Future<dynamic>>[
          getExpensesUseCase(),
          ensureDefaultCategoriesUseCase(),
          getDashboardInsightsUseCase(),
        ],
      );

      final List<Expense> expenses = (response[0] as List<Expense>)
        ..sort(_sortByLatest);
      final List<Category> categories =
          (response[1] as List<dynamic>).cast<Category>();
      final DashboardInsights insights = response[2] as DashboardInsights;

      emit(
        state.copyWith(
          status: DashboardStatus.success,
          allExpenses: expenses,
          categories: categories,
          insights: insights,
          errorMessage: null,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: DashboardStatus.failure,
          errorMessage: _resolveErrorMessage(error),
        ),
      );
    }
  }

  static int _sortByLatest(Expense first, Expense second) {
    return second.date.compareTo(first.date);
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

    return AppApiErrorMessage.unknown;
  }
}
