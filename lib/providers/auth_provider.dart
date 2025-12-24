import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/local_auth_service.dart';

class AuthProvider with ChangeNotifier {
  final LocalAuthService _authService = LocalAuthService.instance;
  UserModel? _currentUser;
  bool _isLoading = true;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;
  int? get currentUserId => _currentUser?.id;

  AuthProvider() {
    _checkAuth();
  }

  // Check if user is already logged in
  Future<void> _checkAuth() async {
    _isLoading = true;
    notifyListeners();

    _currentUser = await _authService.getCurrentUser();

    _isLoading = false;
    notifyListeners();
  }

  // Login user
  Future<Map<String, dynamic>> login(String username, String password) async {
    final result = await _authService.login(
      username: username,
      password: password,
    );

    if (result['success']) {
      _currentUser = result['user'];
      notifyListeners();
    }

    return result;
  }

  // Sign up new user
  Future<Map<String, dynamic>> signUp({
    required String username,
    required String password,
    required String name,
    required double monthlyBudget,
  }) async {
    final result = await _authService.signUp(
      username: username,
      password: password,
      name: name,
      monthlyBudget: monthlyBudget,
    );

    if (result['success']) {
      _currentUser = result['user'];
      notifyListeners();
    }

    return result;
  }

  // Logout user
  Future<void> logout() async {
    await _authService.logout();
    _currentUser = null;
    notifyListeners();
  }

  // Update user profile
  Future<Map<String, dynamic>> updateProfile({
    String? name,
    double? monthlyBudget,
  }) async {
    if (_currentUser == null) {
      return {
        'success': false,
        'message': 'No user logged in',
      };
    }

    final result = await _authService.updateProfile(
      userId: _currentUser!.id!,
      name: name,
      monthlyBudget: monthlyBudget,
    );

    if (result['success']) {
      _currentUser = result['user'];
      notifyListeners();
    }

    return result;
  }

  // Change password
  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (_currentUser == null) {
      return {
        'success': false,
        'message': 'No user logged in',
      };
    }

    return await _authService.changePassword(
      userId: _currentUser!.id!,
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }

  // Refresh current user data
  Future<void> refreshUser() async {
    if (_currentUser == null) return;

    _currentUser = await _authService.getCurrentUser();
    notifyListeners();
  }
}
