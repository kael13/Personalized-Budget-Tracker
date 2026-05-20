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
    );
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

  // Budget Crud
  Future<int> insertBudget(BudgetAllocation budget) async {
    final db = await instance.database;
    return await db.insert('budgets', budget.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<BudgetAllocation>> getBudgets() async {
    final db = await instance.database;
    final result = await db.query('budgets', orderBy: 'created_at DESC');
    return result.map((json) => BudgetAllocation.fromMap(json)).toList();
  }

  Future<int> deleteBudget(String id) async {
    final db = await instance.database;
    return await db.delete('budgets', where: 'id = ?', whereArgs: [id]);
  }

  // Category Crud
  Future<int> insertCategory(Category category) async {
    final db = await instance.database;
    return await db.insert('categories', category.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Category>> getCategories(String budgetId) async {
    final db = await instance.database;
    final result = await db.query('categories', where: 'budget_id = ?', whereArgs: [budgetId]);
    return result.map((json) => Category.fromMap(json)).toList();
  }
}
