import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import '../database/database_helper.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._init();
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  static const String _pushNotificationKey = 'push_notification_enabled';
  bool _isInitialized = false;

  NotificationService._init();

  Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize timezone
    tz.initializeTimeZones();
    
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(initSettings);
    _isInitialized = true;
  }

  Future<bool> requestPermissions() async {
    final androidImplementation = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidImplementation != null) {
      final granted = await androidImplementation.requestNotificationsPermission();
      return granted ?? false;
    }

    final iosImplementation = _notifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    
    if (iosImplementation != null) {
      final granted = await iosImplementation.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    return false;
  }

  Future<void> scheduleDailyExpenseReminder(int userId) async {
    await initialize();

    // Schedule daily notification at 22:00 (10 PM)
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      22, // 10 PM
      0,
    );

    // If it's already past 22:00 today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _notifications.zonedSchedule(
      0, // Notification ID
      'Expense Reminder',
      'Don\'t forget to track your expenses today!',
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder',
          'Daily Expense Reminder',
          channelDescription: 'Daily reminder to track expenses',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // Repeat daily at same time
    );
  }

  Future<void> cancelDailyReminder() async {
    await _notifications.cancel(0);
  }

  Future<void> showBudgetAlert(double percentage, double spent, double budget) async {
    await initialize();

    await _notifications.show(
      1, // Different ID for budget alerts
      'Budget Alert! 🚨',
      'You\'ve used ${percentage.toStringAsFixed(1)}% of your monthly budget.\n'
      'Spent: ৳${spent.toStringAsFixed(0)} / ৳${budget.toStringAsFixed(0)}',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'budget_alert',
          'Budget Alerts',
          channelDescription: 'Alerts when budget threshold is reached',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  Future<void> enablePushNotifications(int userId) async {
    final granted = await requestPermissions();
    if (granted) {
      await scheduleDailyExpenseReminder(userId);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_pushNotificationKey, true);
    }
  }

  Future<void> disablePushNotifications() async {
    await cancelDailyReminder();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_pushNotificationKey, false);
  }

  Future<bool> isPushNotificationEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_pushNotificationKey) ?? false;
  }

  // Check if user added expense in last 24 hours
  Future<bool> hasAddedExpenseToday(int userId) async {
    final dbHelper = DatabaseHelper.instance;
    final yesterday = DateTime.now().subtract(const Duration(hours: 24));
    final expenses = await dbHelper.readExpensesByDateRange(
      userId,
      yesterday,
      DateTime.now(),
    );
    return expenses.isNotEmpty;
  }
}
