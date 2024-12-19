import 'package:alex_k_test/src/core/database/data_base_providers/map_pin_database.dart';
import 'package:alex_k_test/src/core/database/data_base_providers/user_database.dart';
import 'package:alex_k_test/src/core/exceptions/list.dart';
import 'package:alex_k_test/src/core/utils/mappers/universal_mapper.dart';
import 'package:alex_k_test/src/features/data/datasources/local/local_data_sourse.dart';
import 'package:alex_k_test/src/features/data/models/map_pin_model.dart';
import 'package:alex_k_test/src/features/data/models/user_model.dart';

class LocalDataSourceImpl implements LocalDataSource {
  final UserDatabase _userDatabase;
  final MapPinDatabase _mapPinDatabase;
  final UniversalMapper _universalMapper;

  LocalDataSourceImpl(
      this._userDatabase, this._mapPinDatabase, this._universalMapper);

  @override
  Future<void> deleteUser(UserModel userModel) async =>
      await _userDatabase.deleteUser(userModel.id);

  @override
  Future<UserModel?> readUser() async {
    final result = await _userDatabase.getUser();
    return await _universalMapper.tryMap<UserModel>(result, UserModel.fromJson);
  }

  @override
  Future<bool?> saveUser(UserModel userModel) async {
    return await _userDatabase.insertUser(userModel.toJson());
  }

  @override
  Future<List<MapPinModel>?> readMapPins() async {
    final result = await _mapPinDatabase.readMapPins();
    final mapResult = await _universalMapper.tryMapList<MapPinModel>(
        result, MapPinModel.fromJson);
    return mapResult?.removeNulls();
  }

  @override
  Future<List<MapPinModel>?> saveMapPin(MapPinModel mapPinModel) async {
    final result = await _mapPinDatabase.insertMapPin(mapPinModel);
    if (result) {
      // After successful insert, read all pins and return them
      return await readMapPins();
    }
    return null;
  }

  @override
  Future<bool> updateMapPin(MapPinModel mapPinModel) async {
    print("UpdatePin -> ${mapPinModel.id}");
    if (mapPinModel.id == null) {
      return false;
    }
    final result = await _mapPinDatabase.updateMapPin(mapPinModel);
    return result;
  }

  @override
  Future<MapPinModel?> readMapPinByLatLng(double lat, double lng) async {
    final result = await _mapPinDatabase.readMapPinByLatLng(lat, lng);
    final mapResult = await _universalMapper.tryMap<MapPinModel>(
        result, MapPinModel.fromJson);
    return mapResult;
  }

  @override
  Stream<List<MapPinModel>?> observeMapPins() async* {
    yield* _mapPinDatabase.observeAllPins().asyncMap((e) async {
      final mapResult = await _universalMapper.tryMapList<MapPinModel>(
          e, MapPinModel.fromJson);
      return mapResult?.removeNulls();
    });
  }

  @override
  Stream<MapPinModel?> observeSingleMapPin(double id) {
    // TODO: implement observeSingleMapPin
    throw UnimplementedError();
  }
}
