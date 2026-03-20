import 'package:equatable/equatable.dart';

class Expense extends Equatable {
  const Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.categoryId,
    this.currencyCode = 'USD',
    this.fxRateSnapshot = 1,
    this.originalAmount,
    this.location,
    this.notes,
  });

  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final String categoryId;
  final String currencyCode;
  final double fxRateSnapshot;
  final double? originalAmount;
  final String? location;
  final String? notes;

  /// Amount in the original currency — avoids precision loss from
  /// base-currency (USD) round-trip conversion.
  double get displayAmount => originalAmount ?? amount;

  @override
  List<Object?> get props => <Object?>[
        id,
        title,
        amount,
        date,
        categoryId,
        currencyCode,
        fxRateSnapshot,
        originalAmount,
        location,
        notes,
      ];
}

class ExpenseDraft extends Equatable {
  const ExpenseDraft({
    required this.title,
    required this.amount,
    required this.date,
    required this.categoryId,
    this.currencyCode = 'USD',
    this.location,
    this.notes,
  });

  final String title;
  final double amount;
  final DateTime date;
  final String categoryId;
  final String currencyCode;
  final String? location;
  final String? notes;

  @override
  List<Object?> get props => <Object?>[
        title,
        amount,
        date,
        categoryId,
        currencyCode,
        location,
        notes,
      ];
}
