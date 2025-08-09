import 'package:sqflite/sqflite.dart';
import 'app_database.dart';
import '../models/task.dart';

class TaskDao {
  static const table = 'tasks';

  Future<List<Task>> getAll() async {
    final db = await AppDatabase.instance.db;
    final rows = await db.query(table, orderBy: 'created_at DESC');
    return rows.map((e) => Task.fromMap(e)).toList();
  }

  Future<int> insert(Task t) async {
    final db = await AppDatabase.instance.db;
    final id = await db.insert(table, {
      ...t.toMap()..remove('id'),
      'created_at': DateTime.now().millisecondsSinceEpoch,
    });
    return id;
  }

  Future<int> update(Task t) async {
    if (t.id == null) throw ArgumentError('Task id is null');
    final db = await AppDatabase.instance.db;
    return db.update(table, t.toMap()..remove('created_at'),
        where: 'id=?', whereArgs: [t.id]);
  }

  Future<int> delete(int id) async {
    final db = await AppDatabase.instance.db;
    return db.delete(table, where: 'id=?', whereArgs: [id]);
  }

  Future<int> toggleCompleted(int id, bool completed) async {
    final db = await AppDatabase.instance.db;
    return db.update(table, {'is_completed': completed ? 1 : 0},
        where: 'id=?', whereArgs: [id]);
  }
}
