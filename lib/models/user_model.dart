class UserModel {
  final int? id;
  final String username;
  final String passwordHash;
  final String name;
  final double monthlyBudget;
  final DateTime createdAt;

  UserModel({
    this.id,
    required this.username,
    required this.passwordHash,
    required this.name,
    required this.monthlyBudget,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Convert UserModel to Map for database insertion
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'passwordHash': passwordHash,
      'name': name,
      'monthlyBudget': monthlyBudget,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create UserModel from Map (database query result)
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as int?,
      username: map['username'] as String,
      passwordHash: map['passwordHash'] as String,
      name: map['name'] as String,
      monthlyBudget: (map['monthlyBudget'] as num).toDouble(),
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  // Create a copy with modified fields
  UserModel copyWith({
    int? id,
    String? username,
    String? passwordHash,
    String? name,
    double? monthlyBudget,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      passwordHash: passwordHash ?? this.passwordHash,
      name: name ?? this.name,
      monthlyBudget: monthlyBudget ?? this.monthlyBudget,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, username: $username, name: $name, monthlyBudget: $monthlyBudget, createdAt: $createdAt)';
  }
}
