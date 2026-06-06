class Expense {
  final String id;
  final String subCategoryId;
  final double amount;
  final String description;
  final DateTime date;
  final DateTime createdAt;

  Expense({
    required this.id,
    required this.subCategoryId,
    required this.amount,
    this.description = '',
    required this.date,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sub_category_id': subCategoryId,
      'amount': amount,
      'description': description,
      'date': date.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      subCategoryId: map['sub_category_id'],
      amount: (map['amount'] as num).toDouble(),
      description: map['description'] ?? '',
      date: DateTime.parse(map['date']),
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}