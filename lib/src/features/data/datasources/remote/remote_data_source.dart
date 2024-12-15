import 'package:alex_k_test/src/features/data/models/user_model.dart';

abstract interface class RemoteDataSource {
  Future<UserModel?> tryAuth(String email, String password);

  Future<bool> tryLogOut();
}
