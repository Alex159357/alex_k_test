import 'package:alex_k_test/src/features/data/datasources/remote/remote_data_source.dart';
import 'package:alex_k_test/src/features/data/models/user_model.dart';

class RemoteDataSourceImpl implements RemoteDataSource {
  @override
  Future<UserModel?> tryAuth(String email, String password) async {
    return const UserModel(0, "TEST NAME");
  }

  @override
  Future<bool> tryLogOut() {
    throw UnimplementedError();
  }
}
