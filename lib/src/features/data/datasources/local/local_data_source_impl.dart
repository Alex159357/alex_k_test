import 'package:alex_k_test/src/core/database/data_base_providers/user_database.dart';
import 'package:alex_k_test/src/core/utils/mappers/user_mapper.dart';
import 'package:alex_k_test/src/features/data/datasources/local/local_data_sourse.dart';
import 'package:alex_k_test/src/features/data/models/user_model.dart';

class LocalDataSourceImpl implements LocalDataSource {
  final UserDatabase _userDatabase;
  final UserMapper _userMapper;

  LocalDataSourceImpl(this._userDatabase, this._userMapper);

  @override
  Future<void> deleteUser(UserModel userModel) async =>
      await _userDatabase.deleteUser(userModel.id);

  @override
  Future<UserModel?> readUser() async {
    final  result = await _userDatabase.getUser();
    return await _userMapper.tryMap(result);
  }

  @override
  Future<bool?> saveUser(UserModel userModel) async {
    return await _userDatabase.insertUser(userModel.toJson());
  }
}
