import 'package:alex_k_test/src/core/failure/failure.dart';
import 'package:alex_k_test/src/core/network/network_info.dart';
import 'package:alex_k_test/src/core/utils/shared_preferanse/secure_storage.dart';
import 'package:alex_k_test/src/features/data/datasources/local/local_data_sourse.dart';
import 'package:alex_k_test/src/features/data/datasources/remote/remote_data_source.dart';
import 'package:alex_k_test/src/features/data/models/user_model.dart';
import 'package:alex_k_test/src/features/domain/entities/user_entity.dart';
import 'package:alex_k_test/src/features/domain/repositories/user_repository.dart';
import 'package:alex_k_test/src/features/domain/states/secure_storage_keys.dart';
import 'package:either_dart/src/either.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserRepositoryImpl implements UserRepository {
  final NetworkInfo _networkInfo;
  final RemoteDataSource _remoteDataSource;
  final LocalDataSource _localDataSource;
  final SecureStorageController _storageController;

  UserRepositoryImpl(
    this._networkInfo,
    this._remoteDataSource,
    this._localDataSource,
    this._storageController,
  );

  @override
  Future<Either<Failure, UserEntity>> tryAuth(
      String? email, String? password) async {
    try {
      // Check for cached user if offline
      if (!await _networkInfo.isConnected()) {
        return await _handleOfflineAuth();
      }

      // Try online authentication
      return await _tryAuthWithCredentials(email, password);
    } catch (e, stackTrace) {
      if (e is FirebaseAuthException) {
        return Left(_handleFirebaseAuthError(e));
      }
      return Left(
          FailureHandler("UserRepository").logError("tryAuth", "Unknown Error", e, stackTrace));
    }
  }

  Future<Either<Failure, UserEntity>> _handleOfflineAuth() async {
    final dbUser = await _localDataSource.readUser();
    if (dbUser == null) {
      return Left(FailureHandler("UserRepository")
          .logError("_handleOfflineAuth","No cached user data available while offline"));
    }
    if (dbUser.id < 0) {
      return Left(FailureHandler("UserRepository")
          .logError("_handleOfflineAuth", "Cached user not authenticated"));
    }
    return Right(dbUser);
  }

  Future<Either<Failure, UserModel>> _tryAuthWithCredentials(
      String? email, String? password) async {
    final String? cleanEmail = email ??
        await _storageController.read<String?>(
            key: SecureStorageKeys.email, defaultValue: null);

    final cleanPassword = password ??
        await _storageController.read<String?>(
            key: SecureStorageKeys.password, defaultValue: null);

    if (cleanEmail == null || cleanPassword == null) {
      return Left(FailureHandler("UserRepository")
          .logUnfulfilled("Missing credentials for authentication"));
    }

    try {
      final authResult =
          await _remoteDataSource.tryAuth(cleanEmail, cleanPassword);
      if (authResult != null) {
        await _saveCredentials(cleanEmail, cleanPassword, authResult);
        return Right(authResult);
      }
      return Left(
          FailureHandler("UserRepository").logError("Authentication failed", "Auth Failed"));
    } on FirebaseAuthException catch (e) {
      return Left(_handleFirebaseAuthError(e));
    }
  }

  Future<void> _saveCredentials(
      String email, String password, UserModel user) async {
    await _storageController.write(data: email, key: SecureStorageKeys.email);
    await _storageController.write(
        data: password, key: SecureStorageKeys.password);
    await _localDataSource.saveUser(user);
  }

  Failure _handleFirebaseAuthError(FirebaseAuthException e) {
    String message;
    switch (e.code) {
      case 'invalid-email':
        message = 'The email address is badly formatted.';
        break;
      case 'user-disabled':
        message = 'This user account has been disabled.';
        break;
      case 'user-not-found':
        message = 'No user found with this email.';
        break;
      case 'wrong-password':
        message = 'Wrong password provided.';
        break;
      case 'email-already-in-use':
        message = 'Email is already in use by another account.';
        break;
      case 'operation-not-allowed':
        message = 'Email/password accounts are not enabled.';
        break;
      case 'weak-password':
        message = 'The password provided is too weak.';
        break;
      default:
        message = 'Authentication error: ${e.message}';
    }
    return FailureHandler("UserRepository").logError("_handleFirebaseAuthError", message);
  }

  @override
  Future<Either<Failure, bool>> tryLogOut() async {
    try {
      final result = await _remoteDataSource.tryLogOut();
      if (result) {
        await _clearLocalData();
        return const Right(true);
      }
      return Left(
          FailureHandler("UserRepository").logError("tryLogOut", "Failed to log out"));
    } catch (e, stackTrace) {
      return Left(FailureHandler("UserRepository")
          .logError("tryLogOut", "Failed to log out", e, stackTrace));
    }
  }

  Future<void> _clearLocalData() async {
    final currentUser = await _localDataSource.readUser();
    if (currentUser != null) {
      await _localDataSource.deleteUser(currentUser);
    }
    await _storageController.removeByKey(SecureStorageKeys.email);
    await _storageController.removeByKey(SecureStorageKeys.password);
  }
}
