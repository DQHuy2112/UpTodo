import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();
  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    final dir = await getDatabasesPath();
    final path = join(dir, 'uptodo.db');
    _db = await openDatabase(
      path,
      version: 2, // ⬅ nâng version để tạo bảng tasks
      onCreate: (db, version) async {
        // categories (đã có sẵn)
        await db.execute('''
          CREATE TABLE categories(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            icon_code_point INTEGER,
            bg_color INTEGER,
            icon_color INTEGER
          )
        ''');

        // tasks (mới)
        await _createTasks(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _createTasks(db);
        }
      },
    );
    return _db!;
  }

  static Future<void> _createTasks(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS tasks(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        is_completed INTEGER NOT NULL DEFAULT 0,
        category TEXT,
        priority INTEGER NOT NULL,      -- 0:high,1:medium,2:low
        due_date INTEGER,               -- millisSinceEpoch
        time TEXT,
        created_at INTEGER NOT NULL
      )
    ''');
  }
}
