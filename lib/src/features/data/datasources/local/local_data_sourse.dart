

import 'package:alex_k_test/src/features/data/models/map_pin_model.dart';
import 'package:alex_k_test/src/features/data/models/user_model.dart';

abstract interface class LocalDataSource{

  ///SaveMethods
  Future<bool?> saveUser(UserModel userModel);
  Future<List<MapPinModel>?> saveMapPin(MapPinModel mapPinModel);

  ///Read methods
  Future<UserModel?> readUser();
  Future<List<MapPinModel>?> readMapPins();
  Future<MapPinModel?> readMapPinByLatLng(double lat, double lng);

  //Observe
  Stream<List<MapPinModel>?> observeMapPins();
  Stream<MapPinModel?> observeSingleMapPin(double id);

  ///Delete Methods
  Future<void> deleteUser(UserModel userModel);

}