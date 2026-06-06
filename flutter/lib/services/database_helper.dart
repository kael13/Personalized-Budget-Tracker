import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/budget_models.dart';
import '../models/expense_model.dart';
import '../models/savings_goal_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('budgetarian.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
      onConfigure: _onConfigure,
    );
  }

  Future _onConfigure(Database db) async {
    // Enable Foreign Key constraints to support ON DELETE CASCADE
    await db.execute('PRAGMA foreign_keys = ON');
    // Ensure new tables exist (handles both fresh install and migration from v1)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS expenses (
        id TEXT PRIMARY KEY,
        sub_category_id TEXT NOT NULL,
        amount REAL NOT NULL,
        description TEXT,
        date TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (sub_category_id) REFERENCES sub_categories (id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS savings_goals (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        target_amount REAL NOT NULL,
        saved_amount REAL NOT NULL DEFAULT 0,
        deadline TEXT NOT NULL,
        emoji TEXT,
        created_at TEXT NOT NULL
      )
    ''');
  }

Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE budgets (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        total_budget REAL NOT NULL,
        currency TEXT NOT NULL,
        days_to_consume INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        pin TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        budget_id TEXT NOT NULL,
        name TEXT NOT NULL,
        allocated_amount REAL NOT NULL,
        spent_amount REAL NOT NULL,
        FOREIGN KEY (budget_id) REFERENCES budgets (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE sub_categories (
        id TEXT PRIMARY KEY,
        category_id TEXT NOT NULL,
        name TEXT NOT NULL,
        allocated_amount REAL NOT NULL,
        spent_amount REAL NOT NULL,
        FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE CASCADE
      )
    ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS expenses (
          id TEXT PRIMARY KEY,
          sub_category_id TEXT NOT NULL,
          amount REAL NOT NULL,
          description TEXT,
          date TEXT NOT NULL,
          created_at TEXT NOT NULL,
          FOREIGN KEY (sub_category_id) REFERENCES sub_categories (id) ON DELETE CASCADE
        )
      ''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS savings_goals (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          target_amount REAL NOT NULL,
          saved_amount REAL NOT NULL DEFAULT 0,
          deadline TEXT NOT NULL,
          emoji TEXT,
          created_at TEXT NOT NULL
        )
      ''');
    }
  }

  // Nested SQLite Transaction to save a Budget along with its categories and subcategories
  Future<void> saveBudget(BudgetAllocation budget) async {
    final db = await instance.database;

    await db.transaction((txn) async {
      // 1. Insert or update the main Budget record
      await txn.insert(
        'budgets',
        budget.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // 2. Clear old categories (ON DELETE CASCADE will automatically clear subcategories)
      await txn.delete(
        'categories',
        where: 'budget_id = ?',
        whereArgs: [budget.id],
      );

      // 3. Insert categories and their respective subcategories
      for (var category in budget.categories) {
        await txn.insert(
          'categories',
          category.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        for (var subCategory in category.subCategories) {
          await txn.insert(
            'sub_categories',
            subCategory.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }
    });
  }

  // Retrieve nested Budget list
  Future<List<BudgetAllocation>> getBudgets() async {
    final db = await instance.database;

    // 1. Fetch budgets
    final budgetMaps = await db.query('budgets', orderBy: 'created_at DESC');
    final List<BudgetAllocation> budgets = [];

    for (var budgetMap in budgetMaps) {
      final String budgetId = budgetMap['id'] as String;

      // 2. Fetch categories for this budget
      final categoryMaps = await db.query(
        'categories',
        where: 'budget_id = ?',
        whereArgs: [budgetId],
      );

      final List<Category> categories = [];

      for (var categoryMap in categoryMaps) {
        final String categoryId = categoryMap['id'] as String;

        // 3. Fetch subcategories for this category
        final subCategoryMaps = await db.query(
          'sub_categories',
          where: 'category_id = ?',
          whereArgs: [categoryId],
        );

        final List<SubCategory> subCategories = subCategoryMaps
            .map((json) => SubCategory.fromMap(json))
            .toList();

        categories.add(Category.fromMap(categoryMap, subCategories: subCategories));
      }

      budgets.add(BudgetAllocation.fromMap(budgetMap, categories: categories));
    }

    return budgets;
  }

  // Delete budget profile (will trigger ON DELETE CASCADE on children automatically)
  Future<int> deleteBudget(String id) async {
    final db = await instance.database;
    return await db.delete('budgets', where: 'id = ?', whereArgs: [id]);
  }

  // ─── Expenses ─────────────────────────────────────────────────────

  Future<void> saveExpense(Expense expense) async {
    final db = await instance.database;
    await db.insert('expenses', expense.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Expense>> getExpensesBySubCategory(String subCategoryId) async {
    final db = await instance.database;
    final maps = await db.query('expenses',
        where: 'sub_category_id = ?',
        whereArgs: [subCategoryId],
        orderBy: 'date DESC');
    return maps.map((m) => Expense.fromMap(m)).toList();
  }

  Future<List<Expense>> getExpensesByBudget(String budgetId) async {
    final db = await instance.database;
    final maps = await db.rawQuery('''
      SELECT e.* FROM expenses e
      INNER JOIN sub_categories sc ON e.sub_category_id = sc.id
      INNER JOIN categories c ON sc.category_id = c.id
      WHERE c.budget_id = ?
      ORDER BY e.date DESC
    ''', [budgetId]);
    return maps.map((m) => Expense.fromMap(m)).toList();
  }

  Future<void> deleteExpense(String id) async {
    final db = await instance.database;
    await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateSubCategorySpent(String subCategoryId, double totalSpent) async {
    final db = await instance.database;
    await db.update('sub_categories', {'spent_amount': totalSpent},
        where: 'id = ?', whereArgs: [subCategoryId]);
  }

  Future<void> updateCategorySpent(String categoryId, double totalSpent) async {
    final db = await instance.database;
    await db.update('categories', {'spent_amount': totalSpent},
        where: 'id = ?', whereArgs: [categoryId]);
  }

  Future<double> getSubCategoryTotalSpent(String subCategoryId) async {
    final db = await instance.database;
    final result = await db.rawQuery(
        'SELECT COALESCE(SUM(amount), 0) as total FROM expenses WHERE sub_category_id = ?',
        [subCategoryId]);
    return (result.first['total'] as num).toDouble();
  }

  Future<double> getCategoryTotalSpent(String categoryId) async {
    final db = await instance.database;
    final result = await db.rawQuery('''
      SELECT COALESCE(SUM(e.amount), 0) as total FROM expenses e
      INNER JOIN sub_categories sc ON e.sub_category_id = sc.id
      WHERE sc.category_id = ?
    ''', [categoryId]);
    return (result.first['total'] as num).toDouble();
  }

  // ─── Savings Goals ────────────────────────────────────────────────

  Future<void> saveSavingsGoal(SavingsGoal goal) async {
    final db = await instance.database;
    await db.insert('savings_goals', goal.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<SavingsGoal>> getSavingsGoals() async {
    final db = await instance.database;
    final maps = await db.query('savings_goals', orderBy: 'created_at DESC');
    return maps.map((m) => SavingsGoal.fromMap(m)).toList();
  }

  Future<void> deleteSavingsGoal(String id) async {
    final db = await instance.database;
    await db.delete('savings_goals', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> addToSavingsGoal(String id, double amount) async {
    final db = await instance.database;
    await db.rawUpdate(
      'UPDATE savings_goals SET saved_amount = saved_amount + ? WHERE id = ?',
      [amount, id],
    );
  }
}
