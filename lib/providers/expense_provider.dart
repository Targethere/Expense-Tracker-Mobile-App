import 'package:flutter/foundation.dart';
import '../models/expense_model.dart';
import '../database/database_helper.dart';
import 'preferences_provider.dart';
import 'auth_provider.dart';

class ExpenseProvider extends ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  
  // In-memory cache for recent expenses
  List<Expense> _expenses = [];
  bool _isLoading = false;
  String? _error;
  int? _currentUserId;

  // References to other providers (will be set externally)
  PreferencesProvider? _preferencesProvider;
  AuthProvider? _authProvider;

  // Getters
  List<Expense> get expenses => _expenses;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int? get currentUserId => _currentUserId;

  // Set provider dependencies
  void setProviders(PreferencesProvider preferencesProvider, AuthProvider authProvider) {
    _preferencesProvider = preferencesProvider;
    _authProvider = authProvider;
  }

  // Set the current user ID (should be called after login)
  void setUserId(int userId) {
    if (_currentUserId != userId) {
      _currentUserId = userId;
      _expenses.clear();
      loadRecentExpenses();
    }
  }

  // Clear user data (called on logout)
  void clearUser() {
    _currentUserId = null;
    _expenses.clear();
    notifyListeners();
  }

  // Get total amount of all expenses in cache
  double get totalExpenses {
    return _expenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  // Get expenses count
  int get expensesCount => _expenses.length;

  // Load recent expenses from database (called on app start or refresh)
  Future<void> loadRecentExpenses({int limit = 50}) async {
    if (_currentUserId == null) {
      _error = 'No user logged in';
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _expenses = await _databaseHelper.readRecentExpenses(
        userId: _currentUserId!,
        limit: limit,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load all expenses from database
  Future<void> loadAllExpenses() async {
    if (_currentUserId == null) {
      _error = 'No user logged in';
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _expenses = await _databaseHelper.readAllExpenses(_currentUserId!);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add a new expense
  Future<Expense?> addExpense(Expense expense) async {
    if (_currentUserId == null) {
      _error = 'No user logged in';
      notifyListeners();
      return null;
    }

    try {
      final newExpense = await _databaseHelper.createExpense(expense);
      
      // Add to the beginning of the list (most recent first)
      _expenses.insert(0, newExpense);
      notifyListeners();
      
      // Check budget alert after adding expense
      await _checkBudgetAlert();
      
      return newExpense;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  // Check and show budget alert if needed
  Future<void> _checkBudgetAlert() async {
    if (_preferencesProvider == null || _authProvider == null || _currentUserId == null) {
      return;
    }

    final user = _authProvider!.currentUser;
    if (user == null || user.monthlyBudget <= 0) {
      return;
    }

    // Get current month's total spending
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month, 1);
    final endDate = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    
    final monthlyTotal = await _databaseHelper.getTotalExpensesByDateRange(
      _currentUserId!,
      startDate,
      endDate,
    );

    // Check budget alert
    await _preferencesProvider!.checkAndShowBudgetAlert(
      monthlyTotal,
      user.monthlyBudget,
    );
  }

  // Update an existing expense
  Future<bool> updateExpense(Expense expense) async {
    if (_currentUserId == null) {
      _error = 'No user logged in';
      notifyListeners();
      return false;
    }

    try {
      await _databaseHelper.updateExpense(expense);
      
      // Update in the cache
      final index = _expenses.indexWhere((e) => e.id == expense.id);
      if (index != -1) {
        _expenses[index] = expense;
        notifyListeners();
      }
      
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Delete an expense
  Future<bool> deleteExpense(int id) async {
    if (_currentUserId == null) {
      _error = 'No user logged in';
      notifyListeners();
      return false;
    }

    try {
      await _databaseHelper.deleteExpense(id, _currentUserId!);
      
      // Remove from cache
      _expenses.removeWhere((expense) => expense.id == id);
      notifyListeners();
      
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Get expenses by category (from cache)
  List<Expense> getExpensesByCategory(String category) {
    return _expenses.where((expense) => expense.category == category).toList();
  }

  // Get expenses by date range (from cache)
  List<Expense> getExpensesByDateRange(DateTime startDate, DateTime endDate) {
    return _expenses.where((expense) {
      return expense.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
             expense.date.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  // Get total expenses for a specific category (from cache)
  double getTotalByCategory(String category) {
    return _expenses
        .where((expense) => expense.category == category)
        .fold(0.0, (sum, expense) => sum + expense.amount);
  }

  // Get total expenses for a date range (from cache)
  double getTotalByDateRange(DateTime startDate, DateTime endDate) {
    return _expenses
        .where((expense) {
          return expense.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
                 expense.date.isBefore(endDate.add(const Duration(days: 1)));
        })
        .fold(0.0, (sum, expense) => sum + expense.amount);
  }

  // Get expenses by payment method (from cache)
  List<Expense> getExpensesByPaymentMethod(String paymentMethod) {
    return _expenses
        .where((expense) => expense.paymentMethod == paymentMethod)
        .toList();
  }

  // Search expenses by description (from cache)
  List<Expense> searchExpenses(String query) {
    final lowerQuery = query.toLowerCase();
    return _expenses.where((expense) {
      return expense.description.toLowerCase().contains(lowerQuery) ||
             expense.category.toLowerCase().contains(lowerQuery) ||
             (expense.notes?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  // Get expenses for today (from cache)
  List<Expense> getTodayExpenses() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    
    return _expenses.where((expense) {
      return expense.date.isAfter(today.subtract(const Duration(seconds: 1))) &&
             expense.date.isBefore(tomorrow);
    }).toList();
  }

  // Get expenses for current month (from cache)
  List<Expense> getCurrentMonthExpenses() {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
    
    return getExpensesByDateRange(firstDayOfMonth, lastDayOfMonth);
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Refresh expenses from database
  Future<void> refreshExpenses() async {
    await loadRecentExpenses();
  }
}
