import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static final PreferencesService instance = PreferencesService._init();
  PreferencesService._init();

  static SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // User Profile
  Future<void> setUserName(String name) async {
    await init();
    await _prefs!.setString('user_name', name);
  }

  String getUserName() {
    return _prefs?.getString('user_name') ?? 'User';
  }

  Future<void> setUserEmail(String email) async {
    await init();
    await _prefs!.setString('user_email', email);
  }

  String? getUserEmail() {
    return _prefs?.getString('user_email');
  }

  Future<void> setProfileImageUrl(String url) async {
    await init();
    await _prefs!.setString('profile_image_url', url);
  }

  String? getProfileImageUrl() {
    return _prefs?.getString('profile_image_url');
  }

  // Budget
  Future<void> setMonthlyBudget(double budget) async {
    await init();
    await _prefs!.setDouble('monthly_budget', budget);
  }

  double getMonthlyBudget() {
    return _prefs?.getDouble('monthly_budget') ?? 50000.0;
  }

  // Onboarding
  Future<void> setOnboardingCompleted(bool completed) async {
    await init();
    await _prefs!.setBool('onboarding_completed', completed);
  }

  bool isOnboardingCompleted() {
    return _prefs?.getBool('onboarding_completed') ?? false;
  }

  // Google Sign In Status
  Future<void> setGoogleSignedIn(bool signedIn) async {
    await init();
    await _prefs!.setBool('google_signed_in', signedIn);
  }

  bool isGoogleSignedIn() {
    return _prefs?.getBool('google_signed_in') ?? false;
  }

  // Dark Mode
  Future<void> setDarkMode(bool enabled) async {
    await init();
    await _prefs!.setBool('dark_mode', enabled);
  }

  bool getDarkMode() {
    return _prefs?.getBool('dark_mode') ?? false;
  }

  // Budget Alert
  Future<void> setBudgetAlert(bool enabled) async {
    await init();
    await _prefs!.setBool('budget_alert', enabled);
  }

  bool getBudgetAlert() {
    return _prefs?.getBool('budget_alert') ?? true;
  }

  // Budget Alert Threshold (default 80%)
  Future<void> setBudgetAlertThreshold(int percentage) async {
    await init();
    await _prefs!.setInt('budget_alert_threshold', percentage);
  }

  int getBudgetAlertThreshold() {
    return _prefs?.getInt('budget_alert_threshold') ?? 80;
  }

  // Push Notifications
  Future<void> setPushNotifications(bool enabled) async {
    await init();
    await _prefs!.setBool('push_notifications', enabled);
  }

  bool getPushNotifications() {
    return _prefs?.getBool('push_notifications') ?? true;
  }

  // Custom Categories (stored as JSON string list)
  Future<void> setCustomCategories(List<String> categories) async {
    await init();
    await _prefs!.setStringList('custom_categories', categories);
  }

  List<String> getCustomCategories() {
    return _prefs?.getStringList('custom_categories') ?? [];
  }

  Future<void> addCustomCategory(String category) async {
    final categories = getCustomCategories();
    if (!categories.contains(category)) {
      categories.add(category);
      await setCustomCategories(categories);
    }
  }

  Future<void> removeCustomCategory(String category) async {
    final categories = getCustomCategories();
    categories.remove(category);
    await setCustomCategories(categories);
  }

  // Last Backup Date
  Future<void> setLastBackupDate(DateTime date) async {
    await init();
    await _prefs!.setString('last_backup_date', date.toIso8601String());
  }

  DateTime? getLastBackupDate() {
    final dateString = _prefs?.getString('last_backup_date');
    if (dateString != null) {
      return DateTime.parse(dateString);
    }
    return null;
  }

  // Currency (for future use)
  Future<void> setCurrency(String currency) async {
    await init();
    await _prefs!.setString('currency', currency);
  }

  String getCurrency() {
    return _prefs?.getString('currency') ?? '৳';
  }

  // Clear all data (for logout)
  Future<void> clearAllData() async {
    await init();
    await _prefs!.clear();
  }

  // Clear only auth data (keep user preferences)
  Future<void> clearAuthData() async {
    await init();
    await _prefs!.remove('user_email');
    await _prefs!.remove('profile_image_url');
    await _prefs!.remove('google_signed_in');
  }
}
