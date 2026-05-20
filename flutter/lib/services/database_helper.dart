import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/budget_models.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('bloom_budget.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onConfigure: _onConfigure,
    );
  }

  Future _onConfigure(Database db) async {
    // Enable Foreign Key constraints to support ON DELETE CASCADE
    await db.execute('PRAGMA foreign_keys = ON');
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
}
