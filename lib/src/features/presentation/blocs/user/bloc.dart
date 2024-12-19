import 'dart:async';

import 'package:alex_k_test/src/core/failure/failure.dart';
import 'package:alex_k_test/src/core/utils/permissions/permissions_handler.dart';
import 'package:alex_k_test/src/features/domain/entities/user_entity.dart';
import 'package:alex_k_test/src/features/domain/states/auth_state.dart';
import 'package:alex_k_test/src/features/domain/states/general_screen_state.dart';
import 'package:alex_k_test/src/features/domain/usecases/location_usecase.dart';
import 'package:alex_k_test/src/features/domain/usecases/user_usecase.dart';
import 'package:bloc/bloc.dart';

import 'event.dart';
import 'state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {

  UserBloc(this._userUseCase, this._permissionsHandler, this._locationUseCase)
      : super(const UserState().init()) {
    on<InitEvent>(_init);
    on<OnAuthError>(_onAuthError);
    on<OnAuthSuccess>(_onAuthSuccess);
    on<OnPasswordVisibilityChanged>(_onPasswordVisibilityChanged);
    on<OnEmailChanged>(_onEmailChanged);
    on<OnPasswordChanged>(_onPasswordChanged);
    on<OnLoginPressed>(_onLoginPressed);
    on<OnLogoutPressed>(_onLogoutPressed);
    on<OnRestoreScreenState>(_onRestoreScreenState);
    on<OnUserLocationChanged>(_onUserLocationChanged);
  }

  final UserUseCase _userUseCase;
  final PermissionsHandler _permissionsHandler;
  final LocationUseCase _locationUseCase;

  void _authError(Failure failure) {
    if(failure is MessageFailure) {
      add(OnAuthError(failure.message));
    }else{
    }
  }

  void authSuccess(UserEntity userEntity) {
    add(OnAuthSuccess(userEntity));
  }

  void _init(InitEvent event, Emitter<UserState> emit) async {
    emit(state.copyWith(screenState: const LoadingScreenState()));
    final autoAuthResult = await _userUseCase.tryAuth();
    autoAuthResult.fold(_authError, authSuccess);
    emit(state.copyWith(screenState: const InitialScreenState()));
    final permissionResult = await _permissionsHandler.getLocationPermissionsStatus();
    if(permissionResult){
      _locationUseCase.observeLocation().listen((e){
        add(OnUserLocationChanged(e));
      });
    }
  }

  void _onUserLocationChanged(OnUserLocationChanged event, Emitter<UserState> emit) async {
    emit(state.copyWith(userPosition: event.userPositionEntity));
  }

  FutureOr<void> _onAuthError(OnAuthError event, Emitter<UserState> emit) {
    emit(state.copyWith(
      screenState: ErrorScreenState(event.message),
      authState: const UnAuthenticated(),
    ));
  }


  FutureOr<void> _onRestoreScreenState(OnRestoreScreenState event, Emitter<UserState> emit) {
    emit(state.copyWith(
      screenState: const InitialScreenState(),
    ));
  }

  FutureOr<void> _onAuthSuccess(
      OnAuthSuccess event, Emitter<UserState> emit) async {
    _permissionsHandler.requestLocationPermissions();
    emit(state.copyWith(
      screenState: const InitialScreenState(),
      authState: Authenticated(event.userEntity),
    ));
  }

  FutureOr<void> _onPasswordVisibilityChanged(
      OnPasswordVisibilityChanged event, Emitter<UserState> emit) {
    emit(state.copyWith(
      passwordVisibilityState: event.isVisible,
    ));
  }

  FutureOr<void> _onEmailChanged(
      OnEmailChanged event, Emitter<UserState> emit) {
    emit(state.copyWith(
      email: event.email,
    ));
  }

  FutureOr<void> _onPasswordChanged(
      OnPasswordChanged event, Emitter<UserState> emit) {
    emit(state.copyWith(
      password: event.password,
    ));
  }

  FutureOr<void> _onLoginPressed(
      OnLoginPressed event, Emitter<UserState> emit) async {
    if (!_validateCredentials(state.email, state.password)) {
      emit(state.copyWith(
        screenState:
            const ErrorScreenState("Please enter valid email and password"),
      ));
      return;
    }

    emit(state.copyWith(screenState: const LoadingScreenState()));

    final authResult = await _userUseCase.tryAuth(
      email: state.email,
      password: state.password,
    );
    authResult.fold(_authError, authSuccess);
  }

  FutureOr<void> _onLogoutPressed(
      OnLogoutPressed event, Emitter<UserState> emit) async {
    emit(state.copyWith(screenState: const LoadingScreenState()));

    final logoutResult = await _userUseCase.tryLogOut();
    logoutResult.fold(
      (failure) => emit(state.copyWith(
        screenState: ErrorScreenState(failure.message),
      )),
      (success) => emit(state.copyWith(
        screenState: const InitialScreenState(),
        authState: const UnAuthenticated(),
        email: '',
        password: '',
      )),
    );
  }

  bool _validateCredentials(String? email, String? password) {
    if (email == null ||
        email.isEmpty ||
        password == null ||
        password.isEmpty) {
      return false;
    }

    // Basic email validation
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      return false;
    }

    // Basic password validation (at least 6 characters)
    if (password.length < 6) {
      return false;
    }

    return true;
  }

  void logOut() {
    add(const OnLogoutPressed());
  }
}
