import 'dart:async';

import 'package:alex_k_test/src/core/database/database_helper.dart';
import 'package:alex_k_test/src/features/data/models/map_pin_model.dart';
import 'package:logger/logger.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sqflite/sqflite.dart';

class MapPinDatabase {
  final DatabaseHelper _databaseHelper;
  final _logger = Logger();

  MapPinDatabase(this._databaseHelper);

  final _pinsSubject = BehaviorSubject<List<Map<String, dynamic>>>.seeded([]);

  Stream<List<Map<String, dynamic>>> observeAllPins() {
    _onDatabaseUpdated();
    return _pinsSubject.stream;
  }

  Future<List<Map<String, dynamic>>?> readMapPins() async {
    try {
      final db = await _databaseHelper.database;
      final result = await db.query('map_pins');
      _logger.d('Read map pins from database: $result');
      return result;
    } catch (e, t) {
      _logger.e("Error reading map pins", error: e, stackTrace: t);
      return null;
    }
  }

  Stream<Map<String, dynamic>> observeSingleMapPin(double id) {
    return _getSinglePinStream(id);
  }

  Stream<Map<String, dynamic>> _getSinglePinStream(double id) {
    final controller = BehaviorSubject<Map<String, dynamic>>();

    Timer.periodic(const Duration(seconds: 2), (timer) async {
      try {
        final db = await _databaseHelper.database;
        final result = await db.query(
          'map_pins',
          where: 'id = ?',
          whereArgs: [id],
        );

        if (result.isNotEmpty) {
          controller.add(result.first);
        } else {
          controller.addError("Pin with ID $id not found");
        }
      } catch (e, t) {
        _logger.e("Error observing single map pin", error: e, stackTrace: t);
        controller.addError(e);
      }
    });

    return controller.stream;
  }

  Future<Map<String, dynamic>?> readMapPinByLatLng(
      double lat, double lng) async {
    try {
      final db = await _databaseHelper.database;
      final result = await db.query(
        'map_pins',
        where: 'latitude = ? AND longitude = ?',
        whereArgs: [lat, lng],
      );
      _logger
          .d('Read map pin by coordinates: lat=$lat, lng=$lng, result=$result');
      if (result.isNotEmpty) {
        return result.first;
      }
      return null;
    } catch (e, t) {
      _logger.e("Error reading map pin by coordinates",
          error: e, stackTrace: t);
      return null;
    }
  }

  Future<bool> insertMapPin(MapPinModel pin) async {
    try {
      final db = await _databaseHelper.database;
      final json = pin.toJson();
      _logger.d('Inserting map pin: $json');

      // Remove id if it's null to let SQLite auto-generate it
      if (json['id'] == null) {
        json.remove('id');
      }

      final result = await db.insert(
        'map_pins',
        json,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      if (result > 0) {
        _onDatabaseUpdated();
        return true;
      }
      return false;
    } catch (e, t) {
      _logger.e("Error inserting single map pin", error: e, stackTrace: t);
      return false;
    }
  }

  Future<bool> updateMapPin(MapPinModel pin) async {
    try {
      if (pin.id == null) {
        _logger.e("Cannot update pin without ID");
        return false;
      }

      final db = await _databaseHelper.database;
      final json = pin.toJson();
      _logger.d('Updating map pin: $json');

      final result = await db.update(
        'map_pins',
        json,
        where: 'id = ?',
        whereArgs: [pin.id],
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      _onDatabaseUpdated();
      if (result > 0) {
        return true;
      }
      return false;
    } catch (e, t) {
      _logger.e("Error updating map pin", error: e, stackTrace: t);
      return false;
    }
  }

  Future<bool> insertMapPins(List<MapPinModel> pins) async {
    try {
      final db = await _databaseHelper.database;
      final batch = db.batch();

      for (final pin in pins) {
        final json = pin.toJson();
        if (json['id'] == null) {
          json.remove('id');
        }
        _logger.d('Batch inserting map pin: $json');
        batch.insert(
          'map_pins',
          json,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      await batch.commit(noResult: true);
      _onDatabaseUpdated();
      return true;
    } catch (e, t) {
      _logger.e("Error inserting map pins list", error: e, stackTrace: t);
      return false;
    }
  }

  void _onDatabaseUpdated() async {
    try {
      final db = await _databaseHelper.database;
      final result = await db.query('map_pins');
      _logger.d('Database updated, new state: $result');
      _pinsSubject.add(result);
    } catch (e, t) {
      _logger.e("Error updating pins subject", error: e, stackTrace: t);
    }
  }

  Future<void> close() async {
    await _pinsSubject.close();
    await _databaseHelper.close();
  }
}
