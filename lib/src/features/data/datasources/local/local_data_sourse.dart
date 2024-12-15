

import 'package:alex_k_test/src/features/data/models/user_model.dart';

abstract interface class LocalDataSource{

  ///SaveMethods
  Future<bool?> saveUser(UserModel userModel);

  ///Read methods
  Future<UserModel?> readUser();

  ///Delete Methods
  Future<void> deleteUser(UserModel userModel);

}