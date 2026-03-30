import '../../domain/entities/insight.dart';

class MonthlyInsightModel extends MonthlyInsight {
  const MonthlyInsightModel({
    required super.monthDate,
    required super.totalThisMonth,
    required super.totalLastMonth,
    required super.percentageChange,
  });

  factory MonthlyInsightModel.fromJson(Map<String, dynamic> json) {
    // API returns "MMMM yyyy" (e.g. "March 2026") — parse to DateTime so the
    // UI can format it in the correct locale.
    final String monthStr = json['month'] as String? ?? '';
    DateTime monthDate;
    try {
      monthDate = _parseMonthYear(monthStr);
    } catch (_) {
      monthDate = DateTime(DateTime.now().year, DateTime.now().month);
    }

    return MonthlyInsightModel(
      monthDate: monthDate,
      totalThisMonth: (json['totalThisMonth'] as num).toDouble(),
      totalLastMonth: (json['totalLastMonth'] as num).toDouble(),
      percentageChange: (json['percentageChange'] as num).toDouble(),
    );
  }

  /// Parses "MMMM yyyy" (e.g. "March 2026") returned by the server.
  static DateTime _parseMonthYear(String value) {
    final List<String> parts = value.trim().split(' ');
    if (parts.length != 2) throw const FormatException('Unexpected format');

    const Map<String, int> months = <String, int>{
      'january': 1, 'february': 2, 'march': 3, 'april': 4,
      'may': 5, 'june': 6, 'july': 7, 'august': 8,
      'september': 9, 'october': 10, 'november': 11, 'december': 12,
    };

    final int? month = months[parts[0].toLowerCase()];
    final int? year = int.tryParse(parts[1]);
    if (month == null || year == null) throw const FormatException('Unknown month');
    return DateTime(year, month);
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
