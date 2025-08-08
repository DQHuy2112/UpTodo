import 'package:flutter/material.dart';
import 'app_database.dart';

class CategoryEntity {
  final int? id;
  final String name;
  final int? iconCodePoint; // IconData.codePoint
  final int? bgColor;       // Color.value
  final int? iconColor;     // Color.value

  CategoryEntity({
    this.id,
    required this.name,
    this.iconCodePoint,
    this.bgColor,
    this.iconColor,
  });

  Map<String, Object?> toMap() => {
    'id': id,
    'name': name,
    'icon_code_point': iconCodePoint,
    'bg_color': bgColor,
    'icon_color': iconColor,
  };

  factory CategoryEntity.fromMap(Map<String, Object?> m) => CategoryEntity(
    id: m['id'] as int?,
    name: m['name'] as String,
    iconCodePoint: m['icon_code_point'] as int?,
    bgColor: m['bg_color'] as int?,
    iconColor: m['icon_color'] as int?,
  );
}

class CategoryDao {
  Future<List<CategoryEntity>> getAll() async {
    final db = await AppDatabase.instance.db;
    final rows = await db.query('categories', orderBy: 'id ASC');
    return rows.map((e) => CategoryEntity.fromMap(e)).toList();
  }

  Future<int> insert(CategoryEntity e) async {
    final db = await AppDatabase.instance.db;
    return db.insert('categories', e.toMap());
  }

  Future<int> update(CategoryEntity e) async {
    final db = await AppDatabase.instance.db;
    return db.update('categories', e.toMap(), where: 'id=?', whereArgs: [e.id]);
  }

  Future<int> delete(int id) async {
    final db = await AppDatabase.instance.db;
    return db.delete('categories', where: 'id=?', whereArgs: [id]);
  }
}
