import 'package:alex_k_test/src/features/domain/entities/user_entity.dart';
import 'package:flutter/foundation.dart';

@immutable
sealed class UserAuthState {
  const UserAuthState();
}

class UnAuthenticated extends UserAuthState{

  const UnAuthenticated();
}

class Authenticated extends UserAuthState{
  final UserEntity userEntity;

  const Authenticated(this.userEntity);
}
