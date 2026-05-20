import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/budget_models.dart';
import '../services/database_helper.dart';

class AppState extends ChangeNotifier {
  bool _isDarkMode = false;
  List<BudgetAllocation> _budgets = [];
  bool _isLoading = true;
  String _activeTab = 'dashboard'; // 'dashboard', 'analytics', 'calculator'
  bool _isEditMode = false;
  List<String> _selectedBudgetIds = [];

  bool get isDarkMode => _isDarkMode;
  List<BudgetAllocation> get budgets => _budgets;
  bool get isLoading => _isLoading;
  String get activeTab => _activeTab;
  bool get isEditMode => _isEditMode;
  List<String> get selectedBudgetIds => _selectedBudgetIds;

  AppState() {
    _init();
  }

  Future<void> _init() async {
    await loadTheme();
    await loadBudgets();
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
}
