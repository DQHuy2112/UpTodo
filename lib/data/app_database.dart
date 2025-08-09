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
      version: 5, // tăng version để force recreate và fix lỗi
      onCreate: (db, version) async {
        print('Creating database version $version');

        // categories
        await db.execute('''
          CREATE TABLE categories(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            icon_code_point INTEGER,
            bg_color INTEGER,
            icon_color INTEGER
          )
        ''');

        // tasks
        await db.execute('''
          CREATE TABLE tasks(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            description TEXT,
            is_completed INTEGER NOT NULL DEFAULT 0,
            category TEXT,
            priority INTEGER NOT NULL,
            due_date INTEGER,
            time TEXT,
            created_at INTEGER NOT NULL
          )
        ''');

        await db.execute('CREATE INDEX idx_tasks_due ON tasks(due_date)');
        await db.execute(
          'CREATE INDEX idx_tasks_completed ON tasks(is_completed)',
        );

        // profile
        await db.execute('''
          CREATE TABLE profile(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            email TEXT NOT NULL,
            bio TEXT,
            avatar_path TEXT
          )
        ''');

        print('All tables created successfully');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        print('Upgrading database from $oldVersion to $newVersion');

        // Đơn giản hóa: recreate profile table nếu cần
        if (oldVersion < 5) {
          try {
            await db.execute('DROP TABLE IF EXISTS profile');
            await db.execute('''
              CREATE TABLE profile(
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT NOT NULL,
                email TEXT NOT NULL,
                bio TEXT,
                avatar_path TEXT
              )
            ''');
            print('Profile table recreated');
          } catch (e) {
            print('Error recreating profile table: $e');
          }
        }

        // Đảm bảo tasks table tồn tại
        try {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS tasks(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              title TEXT NOT NULL,
              description TEXT,
              is_completed INTEGER NOT NULL DEFAULT 0,
              category TEXT,
              priority INTEGER NOT NULL,
              due_date INTEGER,
              time TEXT,
              created_at INTEGER NOT NULL
            )
          ''');
          await db.execute(
            'CREATE INDEX IF NOT EXISTS idx_tasks_due ON tasks(due_date)',
          );
          await db.execute(
            'CREATE INDEX IF NOT EXISTS idx_tasks_completed ON tasks(is_completed)',
          );
        } catch (e) {
          print('Error ensuring tasks table: $e');
        }
      },
      onOpen: (db) async {
        print('Database opened');
      },
    );
    return _db!;
  }

  // Reset database method cho debugging
  static Future<void> resetDatabase() async {
    try {
      final dir = await getDatabasesPath();
      final path = join(dir, 'uptodo.db');
      await deleteDatabase(path);
      _db = null;
      print('Database reset successfully');
    } catch (e) {
      print('Error resetting database: $e');
    }
  }
}
