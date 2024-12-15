import 'package:alex_k_test/src/core/failure/failure.dart';
import 'package:alex_k_test/src/features/data/models/user_model.dart';
import 'package:alex_k_test/src/features/domain/entities/user_entity.dart';
import 'package:alex_k_test/src/features/domain/repositories/user_repository.dart';
import 'package:either_dart/either.dart';

class UserUseCase {
  final UserRepository _repository;

  UserUseCase(this._repository);

  Future<Either<Failure, UserEntity>> tryAuth(
          {String? email, String? password}) async =>
      await _repository.tryAuth(email, password);
}
