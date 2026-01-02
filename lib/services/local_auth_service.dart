import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../database/database_helper.dart';
import '../models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalAuthService {
  static final LocalAuthService instance = LocalAuthService._init();
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  LocalAuthService._init();

  // Hash password using SHA-256
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Sign up a new user
  Future<Map<String, dynamic>> signUp({
    required String username,
    required String password,
    required String name,
    required double monthlyBudget,
  }) async {
    try {
      // Validate inputs
      if (username.trim().isEmpty || password.trim().isEmpty || name.trim().isEmpty) {
        return {
          'success': false,
          'message': 'All fields are required',
        };
      }

      if (username.length < 3) {
        return {
          'success': false,
          'message': 'Username must be at least 3 characters',
        };
      }

      if (password.length < 6) {
        return {
          'success': false,
          'message': 'Password must be at least 6 characters',
        };
      }

      if (monthlyBudget <= 0) {
        return {
          'success': false,
          'message': 'Monthly budget must be greater than 0',
        };
      }

      // Check if username already exists
      final exists = await _dbHelper.usernameExists(username.trim().toLowerCase());
      if (exists) {
        return {
          'success': false,
          'message': 'Username already exists',
        };
      }

      // Create user
      final hashedPassword = _hashPassword(password);
      final user = UserModel(
        username: username.trim().toLowerCase(),
        passwordHash: hashedPassword,
        name: name.trim(),
        monthlyBudget: monthlyBudget,
      );

      final createdUser = await _dbHelper.createUser(user);

      // Save user session
      await _saveUserSession(createdUser);

      return {
        'success': true,
        'message': 'Account created successfully',
        'user': createdUser,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error creating account: $e',
      };
    }
  }

  // Login existing user
  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    try {
      // Validate inputs
      if (username.trim().isEmpty || password.trim().isEmpty) {
        return {
          'success': false,
          'message': 'Username and password are required',
        };
      }

      // Find user by username
      final user = await _dbHelper.readUserByUsername(username.trim().toLowerCase());
      if (user == null) {
        return {
          'success': false,
          'message': 'Invalid username or password',
        };
      }

      // Verify password
      final hashedPassword = _hashPassword(password);
      if (user.passwordHash != hashedPassword) {
        return {
          'success': false,
          'message': 'Invalid username or password',
        };
      }

      // Save user session
      await _saveUserSession(user);

      return {
        'success': true,
        'message': 'Login successful',
        'user': user,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error logging in: $e',
      };
    }
  }

  // Save user session to SharedPreferences
  Future<void> _saveUserSession(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('userId', user.id!);
    await prefs.setString('username', user.username);
    await prefs.setString('name', user.name);
    await prefs.setDouble('monthlyBudget', user.monthlyBudget);
    await prefs.setBool('isLoggedIn', true);
  }

  // Get current logged in user
  Future<UserModel?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

      if (!isLoggedIn) return null;

      final userId = prefs.getInt('userId');
      if (userId == null) return null;

      final user = await _dbHelper.readUser(userId);
      return user;
    } catch (e) {
      return null;
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  // Get current user ID from session
  Future<int?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId');
  }

  // Logout user
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    await prefs.remove('username');
    await prefs.remove('name');
    await prefs.remove('monthlyBudget');
    await prefs.setBool('isLoggedIn', false);
  }

  // Update user profile
  Future<Map<String, dynamic>> updateProfile({
    required int userId,
    String? name,
    double? monthlyBudget,
  }) async {
    try {
      final user = await _dbHelper.readUser(userId);
      if (user == null) {
        return {
          'success': false,
          'message': 'User not found',
        };
      }

      final updatedUser = user.copyWith(
        name: name ?? user.name,
        monthlyBudget: monthlyBudget ?? user.monthlyBudget,
      );

      await _dbHelper.updateUser(updatedUser);

      // Update session
      await _saveUserSession(updatedUser);

      return {
        'success': true,
        'message': 'Profile updated successfully',
        'user': updatedUser,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error updating profile: $e',
      };
    }
  }

  // Change password
  Future<Map<String, dynamic>> changePassword({
    required int userId,
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = await _dbHelper.readUser(userId);
      if (user == null) {
        return {
          'success': false,
          'message': 'User not found',
        };
      }

      // Verify current password
      final hashedCurrentPassword = _hashPassword(currentPassword);
      if (user.passwordHash != hashedCurrentPassword) {
        return {
          'success': false,
          'message': 'Current password is incorrect',
        };
      }

      if (newPassword.length < 6) {
        return {
          'success': false,
          'message': 'New password must be at least 6 characters',
        };
      }

      // Update password
      final hashedNewPassword = _hashPassword(newPassword);
      final updatedUser = user.copyWith(passwordHash: hashedNewPassword);
      await _dbHelper.updateUser(updatedUser);

      return {
        'success': true,
        'message': 'Password changed successfully',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error changing password: $e',
      };
    }
  }
}
