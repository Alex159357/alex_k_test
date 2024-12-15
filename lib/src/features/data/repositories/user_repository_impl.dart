

import 'package:alex_k_test/src/core/failure/failure.dart';
import 'package:alex_k_test/src/core/network/network_info.dart';
import 'package:alex_k_test/src/core/utils/shared_preferanse/secure_storage.dart';
import 'package:alex_k_test/src/features/data/datasources/local/local_data_sourse.dart';
import 'package:alex_k_test/src/features/data/datasources/remote/remote_data_source.dart';
import 'package:alex_k_test/src/features/data/models/user_model.dart';
import 'package:alex_k_test/src/features/domain/entities/user_entity.dart';
import 'package:alex_k_test/src/features/domain/repositories/user_repository.dart';
import 'package:alex_k_test/src/features/domain/states/secure_storage_keys.dart';
import 'package:alex_k_test/src/features/presentation/blocs/user/event.dart';
import 'package:either_dart/src/either.dart';

class UserRepositoryImpl implements UserRepository{
  final NetworkInfo _networkInfo;
  final RemoteDataSource _remoteDataSource;
  final LocalDataSource _localDataSource;
  final SecureStorageController _storageController;

  UserRepositoryImpl(this._networkInfo, this._remoteDataSource, this._localDataSource, this._storageController);

  @override
  Future<Either<Failure, UserEntity>> tryAuth(String? email, String? password) async {
    final dbUser = await _localDataSource.readUser();
     try{
       if(!await _networkInfo.isConnected()){
         if(dbUser == null){
           //Display demo until user will not login
           return Right(UserModel.getDemo());
         }else{
           if(dbUser.id >= 0) {
             return Right(dbUser);
           }else{
             return Left(FailureHandler("UserRepository").logError("Not Authenticated"));
           }
         }
       }else{
         return _tryAuthWithCredentials(email, password);
       }
    }catch(e, t){
       return Left(FailureHandler("UserRepository").logError("tryAuth", e, t));
    }
  }

  Future<Either<Failure, UserModel>> _tryAuthWithCredentials(String? email, String? password) async{
    final String? cleanEmail = email ?? await _storageController.read<String?>(key: SecureStorageKeys.email, defaultValue: null);
    final cleanPassword = password ?? await _storageController.read<String?>(key: SecureStorageKeys.password, defaultValue: null);
    if(cleanEmail != null && cleanPassword != null){
      final authResult = await _remoteDataSource.tryAuth(cleanEmail, cleanPassword);
      if(authResult != null){
        await _storageController.write(data: cleanEmail, key: SecureStorageKeys.email);
        await _storageController.write(data: cleanPassword, key: SecureStorageKeys.password);
        await _localDataSource.saveUser(authResult);
        return Right(authResult);
      }
    }
    return Left(FailureHandler("UserRepository").logError("tryAuth -> User Not Found"));
  }



  @override
  Future<Either<Failure, bool>> tryLogOut() async {
    return const Right(true);
  }




}

