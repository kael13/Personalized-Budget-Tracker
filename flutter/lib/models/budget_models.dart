
class BudgetAllocation {
  final String id;
  final String name;
  final double totalBudget;
  final String currency;
  final int daysToConsume;
  final DateTime createdAt;
  final String? pin;
  final List<Category> categories;

  BudgetAllocation({
    required this.id,
    required this.name,
    required this.totalBudget,
    this.currency = 'PHP',
    required this.daysToConsume,
    required this.createdAt,
    this.pin,
    required this.categories,
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

  factory BudgetAllocation.fromMap(Map<String, dynamic> map, {List<Category> categories = const []}) {
    return BudgetAllocation(
      id: map['id'],
      name: map['name'],
      totalBudget: (map['total_budget'] as num).toDouble(),
      currency: map['currency'] ?? 'PHP',
      daysToConsume: map['days_to_consume'] as int,
      createdAt: DateTime.parse(map['created_at']),
      pin: map['pin'],
      categories: categories,
    );
  }

  BudgetAllocation copyWith({
    String? id,
    String? name,
    double? totalBudget,
    String? currency,
    int? daysToConsume,
    DateTime? createdAt,
    String? pin,
    List<Category>? categories,
  }) {
    return BudgetAllocation(
      id: id ?? this.id,
      name: name ?? this.name,
      totalBudget: totalBudget ?? this.totalBudget,
      currency: currency ?? this.currency,
      daysToConsume: daysToConsume ?? this.daysToConsume,
      createdAt: createdAt ?? this.createdAt,
      pin: pin ?? this.pin,
      categories: categories ?? this.categories,
    );
  }
}

class Category {
  final String id;
  final String budgetId;
  final String name;
  final double allocatedAmount;
  final double spentAmount;
  final List<SubCategory> subCategories;

  Category({
    required this.id,
    required this.budgetId,
    required this.name,
    required this.allocatedAmount,
    required this.spentAmount,
    required this.subCategories,
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

  factory Category.fromMap(Map<String, dynamic> map, {List<SubCategory> subCategories = const []}) {
    return Category(
      id: map['id'],
      budgetId: map['budget_id'],
      name: map['name'],
      allocatedAmount: (map['allocated_amount'] as num).toDouble(),
      spentAmount: (map['spent_amount'] as num).toDouble(),
      subCategories: subCategories,
    );
  }

  Category copyWith({
    String? id,
    String? budgetId,
    String? name,
    double? allocatedAmount,
    double? spentAmount,
    List<SubCategory>? subCategories,
  }) {
    return Category(
      id: id ?? this.id,
      budgetId: budgetId ?? this.budgetId,
      name: name ?? this.name,
      allocatedAmount: allocatedAmount ?? this.allocatedAmount,
      spentAmount: spentAmount ?? this.spentAmount,
      subCategories: subCategories ?? this.subCategories,
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
      allocatedAmount: (map['allocated_amount'] as num).toDouble(),
      spentAmount: (map['spent_amount'] as num).toDouble(),
    );
  }

  SubCategory copyWith({
    String? id,
    String? categoryId,
    String? name,
    double? allocatedAmount,
    double? spentAmount,
  }) {
    return SubCategory(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      allocatedAmount: allocatedAmount ?? this.allocatedAmount,
      spentAmount: spentAmount ?? this.spentAmount,
    );
  }
}
