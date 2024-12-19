import 'dart:async';

import 'package:alex_k_test/src/core/database/database_helper.dart';
import 'package:logger/logger.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sqflite/sqflite.dart';

class SyncQueueDatabase {
  static const String tableName = 'sync_queue';
  static const String columnId = 'id';
  static const String columnType = 'type';
  static const String columnData = 'data';
  static const String columnCreatedAt = 'createdAt';
  static const String columnIsSynced = 'isSynced';
  static const String columnError = 'error';

  final DatabaseHelper _databaseHelper;
  final Logger _logger = Logger();
  final BehaviorSubject<int> _queueCountSubject =
      BehaviorSubject<int>.seeded(0);

  SyncQueueDatabase(this._databaseHelper) {
    _updateQueueCount();
  }

  Future<void> _updateQueueCount() async {
    try {
      final db = await _databaseHelper.database;
      final count = Sqflite.firstIntValue(
              await db.rawQuery('SELECT COUNT(*) FROM $tableName')) ??
          0;
      _queueCountSubject.add(count);
    } catch (e, stackTrace) {
      _logger.e(
        "Error updating queue count",
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  Stream<int> observeQueueCount() {
    _updateQueueCount();
    return _queueCountSubject.stream;
  }

  Future<bool> insertQueueItem(Map<String, dynamic> raw) async {
    try {
      final db = await _databaseHelper.database;
      final result = await db.insert(
        tableName,
        raw,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      await _updateQueueCount();
      return result > 0;
    } on DatabaseException catch (e, stackTrace) {
      _logger.e(
        "Database error when inserting queue item",
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    } catch (e, stackTrace) {
      _logger.e(
        "Unexpected error when inserting queue item",
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getAllQueueItems() async {
    try {
      final db = await _databaseHelper.database;
      return await db.query(
        tableName,
        orderBy: '$columnCreatedAt ASC',
      );
    } on DatabaseException catch (e, stackTrace) {
      _logger.e(
        "Database error when fetching queue items",
        error: e,
        stackTrace: stackTrace,
      );
      return [];
    } catch (e, stackTrace) {
      _logger.e(
        "Unexpected error when fetching queue items",
        error: e,
        stackTrace: stackTrace,
      );
      return [];
    }
  }

  Future<Map<String, dynamic>?> getQueueItemById(int id) async {
    try {
      final db = await _databaseHelper.database;
      final List<Map<String, dynamic>> result = await db.query(
        tableName,
        where: '$columnId = ?',
        whereArgs: [id],
        limit: 1,
      );
      return result.isNotEmpty ? result.first : null;
    } on DatabaseException catch (e, stackTrace) {
      _logger.e(
        "Database error when fetching queue item by id",
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    } catch (e, stackTrace) {
      _logger.e(
        "Unexpected error when fetching queue item by id",
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  Future<int> updateQueueItem(int id, Map<String, dynamic> data) async {
    try {
      final db = await _databaseHelper.database;
      final result = await db.update(
        tableName,
        data,
        where: '$columnId = ?',
        whereArgs: [id],
      );
      await _updateQueueCount();
      return result;
    } on DatabaseException catch (e, stackTrace) {
      _logger.e(
        "Database error when updating queue item",
        error: e,
        stackTrace: stackTrace,
      );
      return 0;
    } catch (e, stackTrace) {
      _logger.e(
        "Unexpected error when updating queue item",
        error: e,
        stackTrace: stackTrace,
      );
      return 0;
    }
  }

  Future<bool> deleteQueueItem(int id) async {
    try {
      final db = await _databaseHelper.database;
      final result = await db.delete(
        tableName,
        where: '$columnId = ?',
        whereArgs: [id],
      );
      await _updateQueueCount();
      return result > 0;
    } on DatabaseException catch (e, stackTrace) {
      _logger.e(
        "Database error when deleting queue item",
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    } catch (e, stackTrace) {
      _logger.e(
        "Unexpected error when deleting queue item",
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  Future<void> close() async {
    await _queueCountSubject.close();
    await _databaseHelper.close();
  }
}
