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

class FailureHandler{
  final String _tag;

  FailureHandler(this._tag);

  Failure logError(String methodName, [dynamic e, StackTrace? t = null]){
    Logger().e("Error in $_tag", error: e, stackTrace: t);
    return MessageFailure(e.toString());
  }
}