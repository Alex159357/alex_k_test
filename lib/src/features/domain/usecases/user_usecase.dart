import 'package:alex_k_test/src/core/failure/failure.dart';
import 'package:alex_k_test/src/features/domain/entities/user_entity.dart';
import 'package:alex_k_test/src/features/domain/repositories/user_repository.dart';
import 'package:either_dart/either.dart';

class UserUseCase {
  final UserRepository _repository;

  UserUseCase(this._repository);

  Future<Either<Failure, UserEntity>> tryAuth(
          {String? email, String? password}) async =>
      await _repository.tryAuth(email, password);

  Future<Either<Failure, bool>> tryLogOut() async =>
      await _repository.tryLogOut();

  Future<Either<Failure, UserEntity>> getCurrentUser() async =>
      await _repository.getCurrentUser();
}
