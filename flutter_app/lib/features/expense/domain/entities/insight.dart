import 'package:equatable/equatable.dart';

class MonthlyInsight extends Equatable {
  const MonthlyInsight({
    required this.monthDate,
    required this.totalThisMonth,
    required this.totalLastMonth,
    required this.percentageChange,
  });

  final DateTime monthDate;
  final double totalThisMonth;
  final double totalLastMonth;
  final double percentageChange;

  @override
  List<Object?> get props => <Object?>[
        monthDate,
        totalThisMonth,
        totalLastMonth,
        percentageChange,
      ];
}

class CategoryInsight extends Equatable {
  const CategoryInsight({
    required this.categoryName,
    required this.total,
    required this.percentageOfMonth,
  });

  final String? categoryName;
  final double total;
  final double percentageOfMonth;

  @override
  List<Object?> get props => <Object?>[categoryName, total, percentageOfMonth];
}

class DailyAverageInsight extends Equatable {
  const DailyAverageInsight({
    required this.dailyAverage,
    required this.totalThisMonth,
    required this.daysElapsed,
    required this.activeExpenseDays,
  });

  final double dailyAverage;
  final double totalThisMonth;
  final int daysElapsed;
  final int activeExpenseDays;

  @override
  List<Object?> get props => <Object?>[
        dailyAverage,
        totalThisMonth,
        daysElapsed,
        activeExpenseDays,
      ];
}

class TopDayInsight extends Equatable {
  const TopDayInsight({
    required this.topDay,
    required this.weekday,
    required this.total,
  });

  final DateTime? topDay;
  final String? weekday;
  final double total;

  @override
  List<Object?> get props => <Object?>[topDay, weekday, total];
}

class DashboardInsights extends Equatable {
  const DashboardInsights({
    required this.monthly,
    required this.category,
    required this.dailyAverage,
    required this.topDay,
  });

  final MonthlyInsight monthly;
  final CategoryInsight category;
  final DailyAverageInsight dailyAverage;
  final TopDayInsight topDay;

  @override
  List<Object?> get props => <Object?>[monthly, category, dailyAverage, topDay];
}
