import 'package:alex_k_test/src/core/exceptions/string.dart';
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

  const UserState(
      {this.screenState = const InitialScreenState(),
      this.authState = const UnAuthenticated(),
      this.email = "",
      this.password = "",
      this.passwordVisibilityState = true});

  bool get isFormValid => email.isEmail && password.length >= 6;

  UserState init() => const UserState();

  UserState copyWith(
          {GeneralScreenState? screenState,
          UserAuthState? authState,
          String? email,
          String? password,
          bool? passwordVisibilityState}) =>
      UserState(
          screenState: screenState ?? this.screenState,
          authState: authState ?? this.authState,
          email: email ?? this.email,
          password: password ?? this.password,
          passwordVisibilityState:
              passwordVisibilityState ?? this.passwordVisibilityState);
}
