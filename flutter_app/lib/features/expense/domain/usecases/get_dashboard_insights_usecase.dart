import '../entities/insight.dart';
import '../repositories/expense_repository.dart';

class GetDashboardInsightsUseCase {
  const GetDashboardInsightsUseCase(this._repository);

  final ExpenseRepository _repository;

  Future<DashboardInsights> call() async {
    final List<dynamic> response = await Future.wait<dynamic>(<Future<dynamic>>[
      _repository.getMonthlyInsight(),
      _repository.getCategoryInsight(),
      _repository.getDailyAverageInsight(),
      _repository.getTopDayInsight(),
    ]);

    return DashboardInsights(
      monthly: response[0] as MonthlyInsight,
      category: response[1] as CategoryInsight,
      dailyAverage: response[2] as DailyAverageInsight,
      topDay: response[3] as TopDayInsight,
    );
  }
}
