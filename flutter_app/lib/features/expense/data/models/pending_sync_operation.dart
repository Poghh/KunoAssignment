import '../../domain/entities/expense.dart';

enum PendingSyncOperationType {
  createCategory,
  deleteCategory,
  createExpense,
  updateExpense,
  deleteExpense,
}

class PendingSyncOperation {
  const PendingSyncOperation({
    required this.id,
    required this.type,
    required this.entityId,
    required this.payload,
    required this.createdAt,
  });

  final String id;
  final PendingSyncOperationType type;
  final String entityId;
  final Map<String, dynamic> payload;
  final DateTime createdAt;

  PendingSyncOperation copyWith({
    String? id,
    PendingSyncOperationType? type,
    String? entityId,
    Map<String, dynamic>? payload,
    DateTime? createdAt,
  }) {
    return PendingSyncOperation(
      id: id ?? this.id,
      type: type ?? this.type,
      entityId: entityId ?? this.entityId,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'type': _typeToString(type),
      'entityId': entityId,
      'payload': payload,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory PendingSyncOperation.fromJson(Map<String, dynamic> json) {
    final dynamic rawPayload = json['payload'];
    return PendingSyncOperation(
      id: (json['id'] as String?) ?? '',
      type: _typeFromString((json['type'] as String?) ?? ''),
      entityId: (json['entityId'] as String?) ?? '',
      payload:
          rawPayload is Map<String, dynamic> ? rawPayload : <String, dynamic>{},
      createdAt: DateTime.tryParse((json['createdAt'] as String?) ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  ExpenseDraft toExpenseDraft() {
    final String dateText = (payload['date'] as String?) ?? '';
    final DateTime parsedDate = DateTime.tryParse(dateText) ?? DateTime.now();

    return ExpenseDraft(
      title: ((payload['title'] as String?) ?? '').trim(),
      amount: ((payload['amount'] as num?) ?? 0).toDouble(),
      date: DateTime(parsedDate.year, parsedDate.month, parsedDate.day),
      categoryId: ((payload['categoryId'] as String?) ?? '').trim(),
      currencyCode:
          ((payload['currencyCode'] as String?) ?? 'USD').toUpperCase(),
      location: payload['location'] as String?,
      notes: payload['notes'] as String?,
    );
  }
}

PendingSyncOperationType _typeFromString(String value) {
  switch (value) {
    case 'createCategory':
      return PendingSyncOperationType.createCategory;
    case 'createExpense':
      return PendingSyncOperationType.createExpense;
    case 'deleteCategory':
      return PendingSyncOperationType.deleteCategory;
    case 'updateExpense':
      return PendingSyncOperationType.updateExpense;
    case 'deleteExpense':
      return PendingSyncOperationType.deleteExpense;
    default:
      return PendingSyncOperationType.updateExpense;
  }
}

String _typeToString(PendingSyncOperationType type) {
  switch (type) {
    case PendingSyncOperationType.createCategory:
      return 'createCategory';
    case PendingSyncOperationType.createExpense:
      return 'createExpense';
    case PendingSyncOperationType.deleteCategory:
      return 'deleteCategory';
    case PendingSyncOperationType.updateExpense:
      return 'updateExpense';
    case PendingSyncOperationType.deleteExpense:
      return 'deleteExpense';
  }
}
