import 'package:alex_k_test/src/features/domain/entities/user_entity.dart';
import 'package:flutter/foundation.dart';

@immutable
sealed class UserEvent {
  const UserEvent();
}

class InitEvent extends UserEvent {
  const InitEvent();
}

class OnAuthSuccess extends UserEvent {
  final UserEntity userEntity;

  const OnAuthSuccess(this.userEntity);
}

class OnAuthError extends UserEvent {
  final String message;

  const OnAuthError(this.message);
}

class OnPasswordVisibilityChanged extends UserEvent {
  final bool isVisible;

  const OnPasswordVisibilityChanged(this.isVisible);
}

class OnEmailChanged extends UserEvent {
  final String email;

  const OnEmailChanged(this.email);
}

class OnPasswordChanged extends UserEvent {
  final String password;

  const OnPasswordChanged(this.password);
}

class OnLoginPressed extends UserEvent {
  const OnLoginPressed();
}

class OnRestoreScreenState extends UserEvent{

  const OnRestoreScreenState();
}

class OnLogoutPressed extends UserEvent {
  const OnLogoutPressed();
}
