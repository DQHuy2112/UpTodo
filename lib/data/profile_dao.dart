import 'package:sqflite/sqflite.dart';
import '../models/profile.dart';
import 'app_database.dart';

class ProfileDao {
  Future<Profile?> getProfile() async {
    try {
      final db = await AppDatabase.instance.db;
      print('Getting profile from database...');

      final rows = await db.query('profile', orderBy: 'id DESC', limit: 1);
      print('Profile query result: ${rows.length} rows');

      if (rows.isEmpty) {
        print('No profile found');
        return null;
      }

      final profile = Profile.fromMap(rows.first);
      print('Profile loaded: ${profile.name}');
      return profile;
    } catch (e) {
      print('Error getting profile: $e');
      return null;
    }
  }

  Future<int> insert(Profile p) async {
    try {
      final db = await AppDatabase.instance.db;
      print('Inserting profile: ${p.name}');

      final id = await db.insert('profile', p.toMap());
      print('Profile inserted with id: $id');
      return id;
    } catch (e) {
      print('Error inserting profile: $e');
      rethrow;
    }
  }

  Future<int> update(Profile p) async {
    try {
      if (p.id == null) throw Exception('Profile id is null');

      final db = await AppDatabase.instance.db;
      print('Updating profile id: ${p.id}');

      final result = await db.update(
          'profile',
          p.toMap(),
          where: 'id=?',
          whereArgs: [p.id]
      );
      print('Profile update affected $result rows');
      return result;
    } catch (e) {
      print('Error updating profile: $e');
      rethrow;
    }
  }

  Future<int> delete(int id) async {
    try {
      final db = await AppDatabase.instance.db;
      print('Deleting profile id: $id');

      final result = await db.delete('profile', where: 'id=?', whereArgs: [id]);
      print('Profile delete affected $result rows');
      return result;
    } catch (e) {
      print('Error deleting profile: $e');
      rethrow;
    }
  }
}