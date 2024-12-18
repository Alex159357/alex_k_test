

import 'package:alex_k_test/src/core/database/database_helper.dart';
import 'package:logger/logger.dart';
import 'package:sqflite/sqflite.dart';


class UserDatabase {
  final DatabaseHelper _databaseHelper;

  UserDatabase(this._databaseHelper);

  Future<bool> insertUser(Map<String, dynamic> raw) async {
    try {
      final db = await _databaseHelper.database;
      final result = await db.insert(
        'user',
        raw,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return result > 0;
    } catch (e, t) {
      Logger().e("Error when try save user", error: e, stackTrace: t);
      return false;
    }
  }

  Future<Map<String, dynamic>?> getUser() async {
    try {
      final db = await _databaseHelper.database;

      final result = await db.query('user', limit: 1);

      if (result.isNotEmpty) {
        return  result.first;
      }

      return null;
    } catch (e) {
      Logger().e("Error reading user from db", error: e);
      return null;
    }
  }


  Future<Map<String, dynamic>?> getUserById(int id) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> result =
    await db.query('user', where: 'id = ?', whereArgs: [id]);
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> updateUser(int id, String newMessage) async {
    final db = await _databaseHelper.database;
    return await db.update(
      'user',
      {'message': newMessage},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteUser(int id) async {
    final db = await _databaseHelper.database;
    return await db.delete(
      'user',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> close() async {
    await _databaseHelper.close();
  }
}
