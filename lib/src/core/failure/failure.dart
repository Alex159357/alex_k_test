import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

@immutable
sealed class Failure {
  final String message;

  const Failure(this.message);
}

class MessageFailure extends Failure {
  const MessageFailure(super.message);
}

class Unfulfilled extends Failure {
  const Unfulfilled(super.message);
}

class FailureHandler {
  final String _tag;

  FailureHandler(this._tag);

  Unfulfilled logUnfulfilled(String methodName, [dynamic e, StackTrace? t]) {
    Logger().i("Info in $_tag", error: e, stackTrace: t);
    return Unfulfilled(e.toString());
  }

  Failure logError(String methodName, String message, [dynamic e, StackTrace? t]) {
    Logger().e("Error in $_tag", error: e, stackTrace: t);
    return MessageFailure(message);
  }
}
