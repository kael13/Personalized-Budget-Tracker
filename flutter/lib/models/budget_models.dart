import 'dart:convert';

class BudgetAllocation {
  final String id;
  final String name;
  final double totalBudget;
  final String currency;
  final int daysToConsume;
  final DateTime createdAt;
  final String? pin;

  BudgetAllocation({
    required this.id,
    required this.name,
    required this.totalBudget,
    this.currency = 'USD',
    required this.daysToConsume,
    required this.createdAt,
    this.pin,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'total_budget': totalBudget,
      'currency': currency,
      'days_to_consume': daysToConsume,
      'created_at': createdAt.toIso8601String(),
      'pin': pin,
    };
  }

  factory BudgetAllocation.fromMap(Map<String, dynamic> map) {
    return BudgetAllocation(
      id: map['id'],
      name: map['name'],
      totalBudget: map['total_budget'],
      currency: map['currency'] ?? 'USD',
      daysToConsume: map['days_to_consume'],
      createdAt: DateTime.parse(map['created_at']),
      pin: map['pin'],
    );
  }
}

class Category {
  final String id;
  final String budgetId;
  final String name;
  final double allocatedAmount;
  final double spentAmount;

  Category({
    required this.id,
    required this.budgetId,
    required this.name,
    required this.allocatedAmount,
    required this.spentAmount,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'budget_id': budgetId,
      'name': name,
      'allocated_amount': allocatedAmount,
      'spent_amount': spentAmount,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      budgetId: map['budget_id'],
      name: map['name'],
      allocatedAmount: map['allocated_amount'],
      spentAmount: map['spent_amount'],
    );
  }
}

class SubCategory {
  final String id;
  final String categoryId;
  final String name;
  final double allocatedAmount;
  final double spentAmount;

  SubCategory({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.allocatedAmount,
    required this.spentAmount,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category_id': categoryId,
      'name': name,
      'allocated_amount': allocatedAmount,
      'spent_amount': spentAmount,
    };
  }

  factory SubCategory.fromMap(Map<String, dynamic> map) {
    return SubCategory(
      id: map['id'],
      categoryId: map['category_id'],
      name: map['name'],
      allocatedAmount: map['allocated_amount'],
      spentAmount: map['spent_amount'],
    );
  }
}
