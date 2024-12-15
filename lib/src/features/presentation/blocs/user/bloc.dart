import 'dart:async';

import 'package:alex_k_test/src/core/failure/failure.dart';
import 'package:alex_k_test/src/features/domain/entities/user_entity.dart';
import 'package:alex_k_test/src/features/domain/states/auth_state.dart';
import 'package:alex_k_test/src/features/domain/states/general_screen_state.dart';
import 'package:alex_k_test/src/features/domain/use_cases/user_use_case.dart';
import 'package:bloc/bloc.dart';

import 'event.dart';
import 'state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserUseCase _userUseCase;

  UserBloc(this._userUseCase) : super(const UserState().init()) {
    on<InitEvent>(_init);
    on<OnAuthError>(_onAuthError);
    on<OnAuthSuccess>(_onAuthSuccess);
    on<OnPasswordVisibilityChanged>(_onPasswordVisibilityChanged);
    on<OnEmailChanged>(_onEmailChanged);
    on<OnPasswordChanged>(_onPasswordChanged);
    on<OnLoginPressed>(_onLoginPressed);
  }

  void init() => add(const InitEvent());

  void setPasswordVisibilityState(bool isVisible) =>
      add(OnPasswordVisibilityChanged(isVisible));

  void setEmail(String value) => add(OnEmailChanged(value));

  void setPassword(String value) => add(OnPasswordChanged(value));

  void loginPressed() => add(const OnLoginPressed());

  _authError(Failure failure) {
    add(OnAuthError(failure.message));
  }

  authSuccess(UserEntity userEntity) {
    add(OnAuthSuccess(userEntity));
  }

  void _init(InitEvent event, Emitter<UserState> emit) async {
    emit(state.copyWith(screenState: const LoadingScreenState()));
    final autoAuthResult = await _userUseCase.tryAuth();
    autoAuthResult.fold(_authError, authSuccess);
  }

  FutureOr<void> _onAuthError(OnAuthError event, Emitter<UserState> emit) {
    emit(state.copyWith(
        screenState: const InitialScreenState(),
        authState: const UnAuthenticated()));
  }

  FutureOr<void> _onAuthSuccess(OnAuthSuccess event, Emitter<UserState> emit) {
    emit(state.copyWith(
        screenState: const InitialScreenState(),
        authState: Authenticated(event.userEntity)));
  }

  FutureOr<void> _onPasswordVisibilityChanged(
      OnPasswordVisibilityChanged event, Emitter<UserState> emit) {
    emit(state.copyWith(passwordVisibilityState: event.isVisible));
  }

  FutureOr<void> _onEmailChanged(
      OnEmailChanged event, Emitter<UserState> emit) {
    emit(state.copyWith(email: event.email));
  }

  FutureOr<void> _onPasswordChanged(
      OnPasswordChanged event, Emitter<UserState> emit) {
    emit(state.copyWith(password: event.password));
  }

  FutureOr<void> _onLoginPressed(
      OnLoginPressed event, Emitter<UserState> emit) async {
    emit(state.copyWith(screenState: const LoadingScreenState()));
    final autoAuthResult = await _userUseCase.tryAuth(
        email: state.email, password: state.password);
    autoAuthResult.fold(_authError, authSuccess);
  }

  logOut() {}
}
