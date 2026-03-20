import 'package:intl/intl.dart';

import '../../domain/entities/expense.dart';

class ExpenseModel extends Expense {
  const ExpenseModel({
    required super.id,
    required super.title,
    required super.amount,
    required super.date,
    required super.categoryId,
    super.currencyCode,
    super.fxRateSnapshot,
    super.originalAmount,
    super.location,
    super.notes,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    final String rawDate = (json['date'] as String?) ?? '';
    final double originalAmount = (json['amount'] as num).toDouble();
    final double amountInBase =
        (json['amountInBase'] as num?)?.toDouble() ?? originalAmount;
    final String currencyCode =
        (json['currencyCode'] as String?)?.toUpperCase() ?? 'USD';
    final double fxRateSnapshot =
        (json['fxRateSnapshot'] as num?)?.toDouble() ?? 1;

    return ExpenseModel(
      id: json['id'] as String,
      title: json['title'] as String,
      amount: amountInBase,
      date: DateTime.parse(
          rawDate.length >= 10 ? rawDate.substring(0, 10) : rawDate),
      categoryId: json['categoryId'] as String,
      currencyCode: currencyCode,
      fxRateSnapshot: fxRateSnapshot,
      originalAmount: originalAmount,
      location: json['location'] as String?,
      notes: json['notes'] as String?,
    );
  }

  static Map<String, dynamic> draftToJson(ExpenseDraft draft) {
    return <String, dynamic>{
      'title': draft.title,
      'amount': draft.amount,
      'currencyCode': draft.currencyCode,
      'date': DateFormat('yyyy-MM-dd').format(draft.date),
      'categoryId': draft.categoryId,
      'location': draft.location,
      'notes': draft.notes,
    };
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'amount': originalAmount ?? amount,
      'amountInBase': amount,
      'currencyCode': currencyCode,
      'fxRateSnapshot': fxRateSnapshot,
      'date': DateFormat('yyyy-MM-dd').format(date),
      'categoryId': categoryId,
      'location': location,
      'notes': notes,
    };
  }
}
