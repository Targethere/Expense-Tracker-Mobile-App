import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';

class PreferencesProvider with ChangeNotifier {
  bool _budgetAlertEnabled = true;
  bool _pushNotificationEnabled = false;
  
  static const String _budgetAlertKey = 'budget_alert_enabled';
  static const String _lastBudgetAlertDateKey = 'last_budget_alert_date';

  bool get budgetAlertEnabled => _budgetAlertEnabled;
  bool get pushNotificationEnabled => _pushNotificationEnabled;

  PreferencesProvider() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _budgetAlertEnabled = prefs.getBool(_budgetAlertKey) ?? true;
    _pushNotificationEnabled = await NotificationService.instance.isPushNotificationEnabled();
    notifyListeners();
  }

  Future<void> toggleBudgetAlert(bool enabled) async {
    _budgetAlertEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_budgetAlertKey, enabled);
    notifyListeners();
  }

  Future<void> togglePushNotification(bool enabled, int userId) async {
    _pushNotificationEnabled = enabled;
    
    if (enabled) {
      await NotificationService.instance.enablePushNotifications(userId);
    } else {
      await NotificationService.instance.disablePushNotifications();
    }
    
    notifyListeners();
  }

  // Check if we should show budget alert (only once per day)
  Future<bool> shouldShowBudgetAlert() async {
    if (!_budgetAlertEnabled) return false;

    final prefs = await SharedPreferences.getInstance();
    final lastAlertDate = prefs.getString(_lastBudgetAlertDateKey);
    final today = DateTime.now().toIso8601String().split('T')[0];

    if (lastAlertDate == today) {
      return false; // Already showed alert today
    }

    return true;
  }

  Future<void> markBudgetAlertShown() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    await prefs.setString(_lastBudgetAlertDateKey, today);
  }

  Future<void> checkAndShowBudgetAlert(double spent, double budget) async {
    if (!_budgetAlertEnabled) return;

    final percentage = (spent / budget) * 100;
    
    // Show alert if 80% or more is used
    if (percentage >= 80.0) {
      final shouldShow = await shouldShowBudgetAlert();
      if (shouldShow) {
        await NotificationService.instance.showBudgetAlert(percentage, spent, budget);
        await markBudgetAlertShown();
      }
    }
  }
}
