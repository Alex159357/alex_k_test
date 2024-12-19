import 'package:alex_k_test/src/features/data/models/map_pin_model.dart';
import 'package:alex_k_test/src/features/data/models/user_model.dart';

abstract class RemoteDataSource {
  Future<UserModel?> tryAuth(String email, String password);
  Future<bool> tryLogOut();

  /// Uploads a map pin to Firebase and returns the Firebase document ID if successful
  Future<String?> uploadMapPin(MapPinModel pin);

  /// Updates an existing map pin in Firebase using the provided document ID
  Future<bool> updateMapPin(String documentId, MapPinModel pin);

  /// Fetches all map pins for the current user from Firebase
  Future<List<MapPinModel>> fetchMapPins();
}
