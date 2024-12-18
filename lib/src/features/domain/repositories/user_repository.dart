

import 'package:alex_k_test/src/core/failure/failure.dart';
import 'package:alex_k_test/src/features/domain/entities/user_entity.dart';
import 'package:either_dart/either.dart';
import 'package:flutter/foundation.dart';

@immutable
abstract interface class UserRepository{


  Future<Either<Failure, UserEntity>> tryAuth(String? email, String? password);

  Future<Either<Failure, bool>> tryLogOut();

}