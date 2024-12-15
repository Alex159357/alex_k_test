

import 'package:alex_k_test/src/features/domain/states/secure_storage_keys.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecureStorageController{
  final SharedPreferences _preferences;


  SecureStorageController(this._preferences);

  Future<T> read<T>(
      {required SecureStorageKeys key, required T defaultValue}) async {
    try {
      final dynamic object = _preferences.get(key.key);
      return object != null ? object as T : defaultValue;
    } catch (e, t) {
// Log any exceptions that occur during the read operation.
      Logger().e("read hive error", error: e,  stackTrace: t);
      return defaultValue;
    }
  }

  Future<bool> write(
      {required Object data, required SecureStorageKeys key}) async {
    try {
      switch (data.runtimeType) {
        case String:
          return await _writeString(key.key, data as String?);
        case int:
          return await _writeInt(key.key, data as int?);
        case double:
          return await _writeDouble(key.key, data as double?);
        case bool:
          return await _writeBool(key.key, data as bool?);
        default:
// If data type is not supported, log an error and return false.
          Logger().e("Unsupported type for secure storage $data");
          return false;
      }
    } catch (e, t) {
// Log any exceptions that occur during the write operation.
      Logger().e("save hive error", error:  e, stackTrace:  t);
      return false;
    }
  }

  Future<void> removeByKey(SecureStorageKeys key) async {
    await _preferences.remove(key.key);
  }

  Future<bool> _writeString(String key, String? value) async {
    return value != null ? await _preferences.setString(key, value) : false;
  }

  Future<bool> _writeInt(String key, int? value) async {
    return value != null ? await _preferences.setInt(key, value) : false;
  }

  Future<bool> _writeDouble(String key, double? value) async {
    return value != null ? await _preferences.setDouble(key, value) : false;
  }

  Future<bool> _writeBool(String key, bool? value) async {
    return value != null ? await _preferences.setBool(key, value) : false;
  }

}