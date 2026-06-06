import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../models/budget_models.dart';
import '../models/expense_model.dart';
import '../models/savings_goal_model.dart';
import '../services/database_helper.dart';
import '../services/notification_service.dart';

class AppState extends ChangeNotifier {
  bool _isDarkMode = false;
  List<BudgetAllocation> _budgets = [];
  bool _isLoading = true;
  bool _isInitialized = false;
  String _activeTab = 'dashboard'; // 'dashboard', 'analytics', 'calculator'
  bool _isEditMode = false;
  List<String> _selectedBudgetIds = [];

  // Onboarding state
  bool _hasSeenOnboarding = false;

  // Settings fields
  String? _nickname;
  String? _profilePicturePath;
  bool _notificationsEnabled = true;
  bool _notifThresholdAlerts = true;
  bool _notifDailyReminder = true;
  TimeOfDay _notifDailyReminderTime = const TimeOfDay(hour: 20, minute: 0);
  bool _notifExpiryWarnings = true;

  // Expense Logging
  List<Expense> _expenses = [];

  // Savings Goals
  List<SavingsGoal> _savingsGoals = [];

  bool get isDarkMode => _isDarkMode;
  List<BudgetAllocation> get budgets => _budgets;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String get activeTab => _activeTab;
  bool get isEditMode => _isEditMode;
  List<String> get selectedBudgetIds => _selectedBudgetIds;
  List<Expense> get expenses => _expenses;
  List<SavingsGoal> get savingsGoals => _savingsGoals;

  bool get hasSeenOnboarding => _hasSeenOnboarding;

  String? get nickname => _nickname;
  String? get profilePicturePath => _profilePicturePath;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get notifThresholdAlerts => _notifThresholdAlerts;
  bool get notifDailyReminder => _notifDailyReminder;
  TimeOfDay get notifDailyReminderTime => _notifDailyReminderTime;
  bool get notifExpiryWarnings => _notifExpiryWarnings;

  AppState() {
    _init();
  }

  Future<void> _init() async {
    await loadTheme();
    await _loadSettings();
    await loadBudgets();
    await loadSavingsGoals();
    _isInitialized = true;
    notifyListeners();
  }

  // ─── Settings persistence ────────────────────────────────────────

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;
    _nickname = prefs.getString('nickname');
    _profilePicturePath = prefs.getString('profile_picture_path');
    if (_profilePicturePath != null && !File(_profilePicturePath!).existsSync()) {
      _profilePicturePath = null;
      await prefs.remove('profile_picture_path');
    }
    _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
    _notifThresholdAlerts = prefs.getBool('notif_threshold_alerts') ?? true;
    _notifDailyReminder = prefs.getBool('notif_daily_reminder') ?? true;
    final hour = prefs.getInt('notif_reminder_hour') ?? 20;
    final minute = prefs.getInt('notif_reminder_minute') ?? 0;
    _notifDailyReminderTime = TimeOfDay(hour: hour, minute: minute);
    _notifExpiryWarnings = prefs.getBool('notif_expiry_warnings') ?? true;
    notifyListeners();
  }

  Future<void> setNotificationsEnabled(bool val) async {
    _notificationsEnabled = val;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', val);
    if (!val) {
      await NotificationService.instance.cancelAll();
    } else {
      await _rescheduleDailyReminder();
      await checkBudgetsAndNotify();
    }
    notifyListeners();
  }

  Future<void> setNotifThresholdAlerts(bool val) async {
    _notifThresholdAlerts = val;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notif_threshold_alerts', val);
    notifyListeners();
  }

  Future<void> setNotifDailyReminder(bool val) async {
    _notifDailyReminder = val;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notif_daily_reminder', val);
    if (val) {
      await _rescheduleDailyReminder();
    } else {
      await NotificationService.instance.cancelNotification(9999);
    }
    notifyListeners();
  }

  Future<void> setNotifDailyReminderTime(TimeOfDay time) async {
    _notifDailyReminderTime = time;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('notif_reminder_hour', time.hour);
    await prefs.setInt('notif_reminder_minute', time.minute);
    if (_notifDailyReminder) {
      await _rescheduleDailyReminder();
    }
    notifyListeners();
  }

  Future<void> setNotifExpiryWarnings(bool val) async {
    _notifExpiryWarnings = val;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notif_expiry_warnings', val);
    notifyListeners();
  }

  Future<void> _rescheduleDailyReminder() async {
    await NotificationService.instance.scheduleDailyReminder(
      id: 9999,
      title: '🌸 Budgetarian Reminder',
      body: 'Have you logged your spending today? 💖',
      time: _notifDailyReminderTime,
    );
  }

  // ─── Profile picture management ──────────────────────────────────

  Future<void> setProfilePicture(String sourcePath) async {
    final dir = await getApplicationDocumentsDirectory();
    final fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final newPath = p.join(dir.path, fileName);
    await File(sourcePath).copy(newPath);

    if (_profilePicturePath != null) {
      final oldFile = File(_profilePicturePath!);
      if (await oldFile.exists()) await oldFile.delete();
    }

    _profilePicturePath = newPath;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_picture_path', newPath);
    notifyListeners();
  }

  Future<void> removeProfilePicture() async {
    if (_profilePicturePath != null) {
      final oldFile = File(_profilePicturePath!);
      if (await oldFile.exists()) await oldFile.delete();
    }
    _profilePicturePath = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('profile_picture_path');
    notifyListeners();
  }

  Future<void> setNickname(String? val) async {
    _nickname = val?.isEmpty == true ? null : val;
    final prefs = await SharedPreferences.getInstance();
    if (_nickname != null) {
      await prefs.setString('nickname', _nickname!);
    } else {
      await prefs.remove('nickname');
    }
    notifyListeners();
  }

  Future<void> setSeenOnboarding() async {
    _hasSeenOnboarding = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);
    notifyListeners();
  }

  // Load theme preference from SharedPreferences
  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    notifyListeners();
  }

  // Toggle Dark Mode
  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners();
  }

  // Load budgets from SQLite
  Future<void> loadBudgets() async {
    _isLoading = true;
    notifyListeners();
    _budgets = await DatabaseHelper.instance.getBudgets();
    _isLoading = false;
    notifyListeners();
    await checkBudgetsAndNotify();
  }

  Future<void> checkBudgetsAndNotify() async {
    if (!_notificationsEnabled) return;

    for (final budget in _budgets) {
      for (final category in budget.categories) {
        if (_notifThresholdAlerts && category.allocatedAmount > 0) {
          final ratio = category.spentAmount / category.allocatedAmount;
          if (ratio >= 1.0) {
            await NotificationService.instance.showNotification(
              id: '${budget.id}_${category.id}_exceeded'.hashCode,
              title: '🚨 Budget Exceeded',
              body: '${category.name} in "${budget.name}" has exceeded its budget!',
            );
          } else if (ratio >= 0.8) {
            await NotificationService.instance.showNotification(
              id: '${budget.id}_${category.id}_threshold'.hashCode,
              title: '💰 Budget Alert',
              body: '${category.name} in "${budget.name}" is at ${(ratio * 100).toStringAsFixed(0)}%',
            );
          }
        }
      }

      if (_notifExpiryWarnings && budget.daysToConsume <= 3) {
        await NotificationService.instance.showNotification(
          id: '${budget.id}_expiry'.hashCode,
          title: '⏰ Budget Ending Soon',
          body: '"${budget.name}" expires in ${budget.daysToConsume} day${budget.daysToConsume == 1 ? '' : 's'}!',
        );
      }
    }
  }

  // Save budget
  Future<void> saveBudget(BudgetAllocation budget) async {
    await DatabaseHelper.instance.saveBudget(budget);
    await loadBudgets();
  }

  // Delete budget
  Future<void> deleteBudget(String id) async {
    await DatabaseHelper.instance.deleteBudget(id);
    await loadBudgets();
  }

  // Tab control
  void setActiveTab(String tab) {
    _activeTab = tab;
    notifyListeners();
  }

  // Edit Mode actions
  void toggleEditMode() {
    _isEditMode = !_isEditMode;
    if (!_isEditMode) {
      _selectedBudgetIds.clear();
    }
    notifyListeners();
  }

  void toggleSelectBudget(String id) {
    if (_selectedBudgetIds.contains(id)) {
      _selectedBudgetIds.remove(id);
    } else {
      _selectedBudgetIds.add(id);
    }
    notifyListeners();
  }

  void toggleSelectAll(List<String> allIds) {
    if (_selectedBudgetIds.length == allIds.length) {
      _selectedBudgetIds.clear();
    } else {
      _selectedBudgetIds = List.from(allIds);
    }
    notifyListeners();
  }

  Future<void> deleteSelectedBudgets() async {
    if (_selectedBudgetIds.isEmpty) return;
    for (var id in _selectedBudgetIds) {
      await DatabaseHelper.instance.deleteBudget(id);
    }
    _selectedBudgetIds.clear();
    _isEditMode = false;
    await loadBudgets();
  }

  Future<void> bulkPinToggle() async {
    if (_selectedBudgetIds.isEmpty) return;
    
    // Check if at least one selected budget is not pinned
    final anyUnpinned = _budgets.any((b) => _selectedBudgetIds.contains(b.id) && b.pin == null);
    final String? newPinState = anyUnpinned ? "true" : null;

    for (var budget in _budgets) {
      if (_selectedBudgetIds.contains(budget.id)) {
        final updated = budget.copyWith(pin: newPinState);
        await DatabaseHelper.instance.saveBudget(updated);
      }
    }

    _selectedBudgetIds.clear();
    _isEditMode = false;
    await loadBudgets();
  }

  // ─── Expense Logging ──────────────────────────────────────────────

  String _generateId() => Random().nextInt(10000000).toString();

  Future<void> logExpense({
    required String subCategoryId,
    required double amount,
    required String description,
    required DateTime date,
  }) async {
    final expense = Expense(
      id: _generateId(),
      subCategoryId: subCategoryId,
      amount: amount,
      description: description,
      date: date,
      createdAt: DateTime.now(),
    );

    await DatabaseHelper.instance.saveExpense(expense);

    // Recalculate spent amounts
    final subTotal = await DatabaseHelper.instance.getSubCategoryTotalSpent(subCategoryId);
    await DatabaseHelper.instance.updateSubCategorySpent(subCategoryId, subTotal);

    // Find category for this subcategory
    for (var budget in _budgets) {
      for (var cat in budget.categories) {
        final subIdx = cat.subCategories.indexWhere((s) => s.id == subCategoryId);
        if (subIdx != -1) {
          final catTotal = await DatabaseHelper.instance.getCategoryTotalSpent(cat.id);
          await DatabaseHelper.instance.updateCategorySpent(cat.id, catTotal);
        }
      }
    }

    await loadBudgets();
  }

  Future<void> deleteExpense(String expenseId) async {
    final expense = _expenses.firstWhere((e) => e.id == expenseId);
    final subCategoryId = expense.subCategoryId;

    await DatabaseHelper.instance.deleteExpense(expenseId);

    final subTotal = await DatabaseHelper.instance.getSubCategoryTotalSpent(subCategoryId);
    await DatabaseHelper.instance.updateSubCategorySpent(subCategoryId, subTotal);

    for (var budget in _budgets) {
      for (var cat in budget.categories) {
        final subIdx = cat.subCategories.indexWhere((s) => s.id == subCategoryId);
        if (subIdx != -1) {
          final catTotal = await DatabaseHelper.instance.getCategoryTotalSpent(cat.id);
          await DatabaseHelper.instance.updateCategorySpent(cat.id, catTotal);
        }
      }
    }

    await loadBudgets();
  }

  Future<List<Expense>> getExpensesForBudget(String budgetId) async {
    return await DatabaseHelper.instance.getExpensesByBudget(budgetId);
  }

  Future<List<Expense>> getExpensesForSubCategory(String subCategoryId) async {
    return await DatabaseHelper.instance.getExpensesBySubCategory(subCategoryId);
  }

  // ─── Savings Goals ────────────────────────────────────────────────

  Future<void> loadSavingsGoals() async {
    _savingsGoals = await DatabaseHelper.instance.getSavingsGoals();
    notifyListeners();
  }

  Future<void> addSavingsGoal(SavingsGoal goal) async {
    await DatabaseHelper.instance.saveSavingsGoal(goal);
    await loadSavingsGoals();
  }

  Future<void> addToFund(String goalId, double amount) async {
    await DatabaseHelper.instance.addToSavingsGoal(goalId, amount);
    await loadSavingsGoals();
  }

  Future<void> deleteSavingsGoal(String id) async {
    await DatabaseHelper.instance.deleteSavingsGoal(id);
    await loadSavingsGoals();
  }
}
