class SavingsGoal {
  final String id;
  final String name;
  final double targetAmount;
  final double savedAmount;
  final DateTime deadline;
  final String emoji;
  final DateTime createdAt;

  SavingsGoal({
    required this.id,
    required this.name,
    required this.targetAmount,
    this.savedAmount = 0,
    required this.deadline,
    this.emoji = '🌟',
    required this.createdAt,
  });

  double get progress => targetAmount > 0 ? (savedAmount / targetAmount).clamp(0.0, 1.0) : 0.0;
  bool get isComplete => savedAmount >= targetAmount;
  int get daysLeft => deadline.difference(DateTime.now()).inDays;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'target_amount': targetAmount,
      'saved_amount': savedAmount,
      'deadline': deadline.toIso8601String(),
      'emoji': emoji,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory SavingsGoal.fromMap(Map<String, dynamic> map) {
    return SavingsGoal(
      id: map['id'],
      name: map['name'],
      targetAmount: (map['target_amount'] as num).toDouble(),
      savedAmount: (map['saved_amount'] as num).toDouble(),
      deadline: DateTime.parse(map['deadline']),
      emoji: map['emoji'] ?? '🌟',
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  SavingsGoal copyWith({
    String? id,
    String? name,
    double? targetAmount,
    double? savedAmount,
    DateTime? deadline,
    String? emoji,
    DateTime? createdAt,
  }) {
    return SavingsGoal(
      id: id ?? this.id,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      savedAmount: savedAmount ?? this.savedAmount,
      deadline: deadline ?? this.deadline,
      emoji: emoji ?? this.emoji,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}