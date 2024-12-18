import 'package:alex_k_test/src/core/database/database_helper.dart';
import 'package:logger/logger.dart';
import 'package:sqflite/sqflite.dart';

class SyncQueueDatabase {
  final DatabaseHelper _databaseHelper;

  SyncQueueDatabase(this._databaseHelper);

  Future<bool> insertQueueItem(Map<String, dynamic> raw) async {
    try {
      final db = await _databaseHelper.database;
      final result = await db.insert(
        'sync_queue',
        raw,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return result > 0;
    } catch (e, t) {
      Logger()
          .e("Error when trying to save queue item", error: e, stackTrace: t);
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getAllQueueItems() async {
    try {
      final db = await _databaseHelper.database;
      return await db.query('sync_queue');
    } catch (e) {
      Logger().e("Error reading queue items from db", error: e);
      return [];
    }
  }

  Future<Map<String, dynamic>?> getQueueItemById(int id) async {
    try {
      final db = await _databaseHelper.database;
      final List<Map<String, dynamic>> result =
          await db.query('sync_queue', where: 'id = ?', whereArgs: [id]);
      return result.isNotEmpty ? result.first : null;
    } catch (e) {
      Logger().e("Error reading queue item from db", error: e);
      return null;
    }
  }

  Future<int> updateQueueItem(int id, Map<String, dynamic> data) async {
    try {
      final db = await _databaseHelper.database;
      return await db.update(
        'sync_queue',
        data,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      Logger().e("Error updating queue item", error: e);
      return 0;
    }
  }

  Future<bool> deleteQueueItem(int id) async {
    try {
      final db = await _databaseHelper.database;
      final result = await db.delete(
        'sync_queue',
        where: 'id = ?',
        whereArgs: [id],
      );
      return result > 0;
    } catch (e) {
      Logger().e("Error deleting queue item", error: e);
      return false;
    }
  }

  Future<void> close() async {
    await _databaseHelper.close();
  }
}
