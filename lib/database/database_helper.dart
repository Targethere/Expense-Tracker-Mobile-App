import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/expense_model.dart';
import '../models/user_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('expenses.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const realType = 'REAL NOT NULL';
    const intType = 'INTEGER NOT NULL';

    // Create users table
    await db.execute('''
      CREATE TABLE users (
        id $idType,
        username $textType UNIQUE,
        passwordHash $textType,
        name $textType,
        monthlyBudget $realType,
        createdAt $textType
      )
    ''');

    // Create expenses table with user_id foreign key
    await db.execute('''
      CREATE TABLE expenses (
        id $idType,
        userId $intType,
        amount $realType,
        description $textType,
        category $textType,
        paymentMethod $textType,
        date $textType,
        notes TEXT,
        createdAt $textType,
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      const textType = 'TEXT NOT NULL';
      const realType = 'REAL NOT NULL';
      const intType = 'INTEGER NOT NULL';
      const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';

      // Create users table
      await db.execute('''
        CREATE TABLE users (
          id $idType,
          username $textType UNIQUE,
          passwordHash $textType,
          name $textType,
          monthlyBudget $realType,
          createdAt $textType
        )
      ''');

      // Create a default user for existing data
      await db.insert('users', {
        'username': 'default_user',
        'passwordHash': '',
        'name': 'Default User',
        'monthlyBudget': 50000.0,
        'createdAt': DateTime.now().toIso8601String(),
      });

      // Add userId column to existing expenses table
      await db.execute('ALTER TABLE expenses ADD COLUMN userId $intType DEFAULT 1');
    }
  }

  // ============ USER OPERATIONS ============

  // Create/Insert a new user
  Future<UserModel> createUser(UserModel user) async {
    final db = await database;
    final id = await db.insert('users', user.toMap());
    return user.copyWith(id: id);
  }

  // Read a user by username
  Future<UserModel?> readUserByUsername(String username) async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );

    if (maps.isNotEmpty) {
      return UserModel.fromMap(maps.first);
    } else {
      return null;
    }
  }

  // Read a user by ID
  Future<UserModel?> readUser(int id) async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return UserModel.fromMap(maps.first);
    } else {
      return null;
    }
  }

  // Update user
  Future<int> updateUser(UserModel user) async {
    final db = await database;
    return db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  // Check if username exists
  Future<bool> usernameExists(String username) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );
    return result.isNotEmpty;
  }

  // ============ EXPENSE OPERATIONS ============

  // Create/Insert a new expense
  Future<Expense> createExpense(Expense expense) async {
    final db = await database;
    final id = await db.insert('expenses', expense.toMap());
    return expense.copyWith(id: id);
  }

  // Read a single expense by ID and userId
  Future<Expense?> readExpense(int id, int userId) async {
    final db = await database;
    final maps = await db.query(
      'expenses',
      columns: [
        'id',
        'userId',
        'amount',
        'description',
        'category',
        'paymentMethod',
        'date',
        'notes',
        'createdAt',
      ],
      where: 'id = ? AND userId = ?',
      whereArgs: [id, userId],
    );

    if (maps.isNotEmpty) {
      return Expense.fromMap(maps.first);
    } else {
      return null;
    }
  }

  // Read all expenses for a user
  Future<List<Expense>> readAllExpenses(int userId) async {
    final db = await database;
    const orderBy = 'date DESC';
    final result = await db.query(
      'expenses',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: orderBy,
    );
    return result.map((json) => Expense.fromMap(json)).toList();
  }

  // Read expenses with limit (for recent expenses)
  Future<List<Expense>> readRecentExpenses({required int userId, int limit = 50}) async {
    final db = await database;
    final result = await db.query(
      'expenses',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
      limit: limit,
    );
    return result.map((json) => Expense.fromMap(json)).toList();
  }

  // Read expenses by date range for a user
  Future<List<Expense>> readExpensesByDateRange(
    int userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await database;
    final result = await db.query(
      'expenses',
      where: 'userId = ? AND date BETWEEN ? AND ?',
      whereArgs: [
        userId,
        startDate.toIso8601String(),
        endDate.toIso8601String(),
      ],
      orderBy: 'date DESC',
    );
    return result.map((json) => Expense.fromMap(json)).toList();
  }

  // Read expenses by category for a user
  Future<List<Expense>> readExpensesByCategory(int userId, String category) async {
    final db = await database;
    final result = await db.query(
      'expenses',
      where: 'userId = ? AND category = ?',
      whereArgs: [userId, category],
      orderBy: 'date DESC',
    );
    return result.map((json) => Expense.fromMap(json)).toList();
  }

  // Update an expense
  Future<int> updateExpense(Expense expense) async {
    final db = await database;
    return db.update(
      'expenses',
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  // Delete an expense
  Future<int> deleteExpense(int id, int userId) async {
    final db = await database;
    return await db.delete(
      'expenses',
      where: 'id = ? AND userId = ?',
      whereArgs: [id, userId],
    );
  }

  // Delete all expenses for a user
  Future<int> deleteAllExpenses(int userId) async {
    final db = await database;
    return await db.delete(
      'expenses',
      where: 'userId = ?',
      whereArgs: [userId],
    );
  }

  // Get total expenses for a user
  Future<double> getTotalExpenses(int userId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM expenses WHERE userId = ?',
      [userId],
    );
    final total = result.first['total'];
    return total != null ? total as double : 0.0;
  }

  // Get total expenses for a specific category and user
  Future<double> getTotalExpensesByCategory(int userId, String category) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM expenses WHERE userId = ? AND category = ?',
      [userId, category],
    );
    final total = result.first['total'];
    return total != null ? total as double : 0.0;
  }

  // Get total expenses for a date range and user
  Future<double> getTotalExpensesByDateRange(
    int userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM expenses WHERE userId = ? AND date BETWEEN ? AND ?',
      [userId, startDate.toIso8601String(), endDate.toIso8601String()],
    );
    final total = result.first['total'];
    return total != null ? total as double : 0.0;
  }

  // Close database
  Future close() async {
    final db = await database;
    db.close();
  }
}
