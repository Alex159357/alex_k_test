import 'package:flutter/foundation.dart';

@immutable
sealed class GeneralScreenState {
  const GeneralScreenState();
}

class InitialScreenState extends GeneralScreenState {
  const InitialScreenState();
}

class LoadingScreenState extends GeneralScreenState {
  const LoadingScreenState();
}

class ErrorScreenState extends GeneralScreenState {
  final String message;

  const ErrorScreenState(this.message);
}
