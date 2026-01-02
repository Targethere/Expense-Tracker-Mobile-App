class Expense {
  final int? id;
  final int userId;
  final double amount;
  final String description;
  final String category;
  final String paymentMethod;
  final DateTime date;
  final String? notes;
  final DateTime createdAt;

  Expense({
    this.id,
    required this.userId,
    required this.amount,
    required this.description,
    required this.category,
    required this.paymentMethod,
    required this.date,
    this.notes,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Convert Expense object to Map for database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'amount': amount,
      'description': description,
      'category': category,
      'paymentMethod': paymentMethod,
      'date': date.toIso8601String(),
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create Expense object from Map (from database)
  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'] as int?,
      userId: map['userId'] as int,
      amount: map['amount'] as double,
      description: map['description'] as String,
      category: map['category'] as String,
      paymentMethod: map['paymentMethod'] as String,
      date: DateTime.parse(map['date'] as String),
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  // Create a copy of Expense with modified fields
  Expense copyWith({
    int? id,
    int? userId,
    double? amount,
    String? description,
    String? category,
    String? paymentMethod,
    DateTime? date,
    String? notes,
    DateTime? createdAt,
  }) {
    return Expense(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      category: category ?? this.category,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Expense(id: $id, amount: $amount, description: $description, category: $category, date: $date)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Expense &&
        other.id == id &&
        other.userId == userId &&
        other.amount == amount &&
        other.description == description &&
        other.category == category &&
        other.paymentMethod == paymentMethod &&
        other.date == date &&
        other.notes == notes;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        amount.hashCode ^
        description.hashCode ^
        category.hashCode ^
        paymentMethod.hashCode ^
        date.hashCode ^
        notes.hashCode;
  }
}
