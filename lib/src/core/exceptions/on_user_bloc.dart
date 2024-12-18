

import 'package:alex_k_test/src/features/presentation/blocs/user/bloc.dart';
import 'package:alex_k_test/src/features/presentation/blocs/user/event.dart';

extension OnUserBloc on UserBloc {
  void init() => add(const InitEvent());

  void setPasswordVisibilityState(bool isVisible) =>
      add(OnPasswordVisibilityChanged(isVisible));

  void setEmail(String value) => add(OnEmailChanged(value));

  void setPassword(String value) => add(OnPasswordChanged(value));

  void loginPressed() => add(const OnLoginPressed());

  void restoreScreenState() => add(const OnRestoreScreenState());
}