import '../../domain/entities/insight.dart';

class MonthlyInsightModel extends MonthlyInsight {
  const MonthlyInsightModel({
    required super.month,
    required super.totalThisMonth,
    required super.totalLastMonth,
    required super.percentageChange,
  });

  factory MonthlyInsightModel.fromJson(Map<String, dynamic> json) {
    return MonthlyInsightModel(
      month: json['month'] as String,
      totalThisMonth: (json['totalThisMonth'] as num).toDouble(),
      totalLastMonth: (json['totalLastMonth'] as num).toDouble(),
      percentageChange: (json['percentageChange'] as num).toDouble(),
    );
  }
}

class CategoryInsightModel extends CategoryInsight {
  const CategoryInsightModel({
    required super.categoryName,
    required super.total,
    required super.percentageOfMonth,
  });

  factory CategoryInsightModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? mostSpentCategory =
        json['mostSpentCategory'] as Map<String, dynamic>?;

    return CategoryInsightModel(
      categoryName: mostSpentCategory?['name'] as String?,
      total: (json['total'] as num).toDouble(),
      percentageOfMonth: (json['percentageOfMonth'] as num).toDouble(),
    );
  }
}

class DailyAverageInsightModel extends DailyAverageInsight {
  const DailyAverageInsightModel({
    required super.dailyAverage,
    required super.totalThisMonth,
    required super.daysElapsed,
    required super.activeExpenseDays,
  });

  factory DailyAverageInsightModel.fromJson(Map<String, dynamic> json) {
    return DailyAverageInsightModel(
      dailyAverage: (json['dailyAverage'] as num).toDouble(),
      totalThisMonth: (json['totalThisMonth'] as num).toDouble(),
      daysElapsed: (json['daysElapsed'] as num).toInt(),
      activeExpenseDays: (json['activeExpenseDays'] as num).toInt(),
    );
  }
}

class TopDayInsightModel extends TopDayInsight {
  const TopDayInsightModel({
    required super.topDay,
    required super.weekday,
    required super.total,
  });

  factory TopDayInsightModel.fromJson(Map<String, dynamic> json) {
    final String? topDay = json['topDay'] as String?;

    return TopDayInsightModel(
      topDay: topDay == null || topDay.isEmpty ? null : DateTime.parse(topDay),
      weekday: json['weekday'] as String?,
      total: (json['total'] as num).toDouble(),
    );
  }
}
