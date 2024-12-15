

import 'dart:async';
import 'dart:convert';

import 'package:alex_k_test/src/features/data/models/user_model.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class UserMapper{

  Future<UserModel?> tryMap(Map<String, dynamic>? raw) async{
    return compute(runMapper, raw);
  }
}

@pragma('vm:entry-point')
FutureOr<UserModel?> runMapper(dynamic rawData) {
  print("Error mapping user ${rawData.runtimeType}");
  // try {
  //   if (rawData == null) return null;
  //
  //   final parsedData = jsonDecode(rawData.toString());
  //   if (parsedData is Map<String, dynamic>) {
  //     Logger().d("Mapped User: $parsedData");
  //     return UserModel.fromJson(parsedData);
  //   }
  //
  //   throw FormatException("Invalid data format");
  // } catch (e, t) {
  //   Logger().e("Error mapping user", error: e, stackTrace: t);
  // }
  return null;
}