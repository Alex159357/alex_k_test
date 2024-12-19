import 'package:alex_k_test/src/core/exceptions/string.dart';
import 'package:alex_k_test/src/features/data/models/user_position_model.dart';
import 'package:alex_k_test/src/features/domain/entities/user_position_entity.dart';
import 'package:alex_k_test/src/features/domain/states/auth_state.dart';
import 'package:alex_k_test/src/features/domain/states/general_screen_state.dart';
import 'package:flutter/foundation.dart';

@immutable
class UserState {
  final GeneralScreenState screenState;
  final UserAuthState authState;
  final String email;
  final String password;
  final bool passwordVisibilityState;
  final UserPositionEntity userPosition;

  const UserState(
      {this.screenState = const InitialScreenState(),
      this.authState = const UnAuthenticated(),
      this.email = "alex_karpov@asd.asd",
      this.password = "159357",
      this.passwordVisibilityState = true,
      this.userPosition = const UserPositionModel(100, 100, 946684800)});

  bool get isFormValid => email.isEmail && password.length >= 6;

  UserState init() => const UserState();

  UserState copyWith(
          {GeneralScreenState? screenState,
          UserAuthState? authState,
          String? email,
          String? password,
          bool? passwordVisibilityState,
          UserPositionEntity? userPosition}) =>
      UserState(
          screenState: screenState ?? this.screenState,
          authState: authState ?? this.authState,
          email: email ?? this.email,
          password: password ?? this.password,
          passwordVisibilityState:
              passwordVisibilityState ?? this.passwordVisibilityState,
          userPosition: userPosition ?? this.userPosition);
}
