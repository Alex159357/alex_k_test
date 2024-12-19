import 'package:alex_k_test/src/features/data/models/map_pin_model.dart';
import 'package:alex_k_test/src/features/data/models/user_model.dart';

abstract class LocalDataSource {
  Future<UserModel?> readUser();
  Future<bool?> saveUser(UserModel userModel);
  Future<void> deleteUser(UserModel userModel);

  Future<List<MapPinModel>?> readMapPins();
  Future<List<MapPinModel>?> saveMapPin(MapPinModel mapPinModel);
  Future<bool> updateMapPin(MapPinModel mapPinModel);
  Future<MapPinModel?> readMapPinByLatLng(double lat, double lng);
  Stream<List<MapPinModel>?> observeMapPins();
  Stream<MapPinModel?> observeSingleMapPin(double id);
}
