
import 'dart:async';

import 'package:alex_k_test/src/features/data/models/serialized_model.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class UniversalMapper {
  Future<T?> tryMap<T extends SerializedModel>(Map<String, dynamic>? raw,
      T Function(Map<String, dynamic>) fromJsonFunction,
      ) async {
    return compute(runMapper<T>, [raw, fromJsonFunction]);
  }

  Future<List<T?>?> tryMapList<T extends SerializedModel>(
      dynamic raw,
      T Function(Map<String, dynamic>) fromJsonFunction,
      ) async {
    if (raw is List) {
      return await compute(runMapperList<T>, [raw, fromJsonFunction]);
    } else if (raw is Map<String, dynamic>) {
      return [await compute(runMapper<T>, [raw, fromJsonFunction])];
    } else {
      return null;
    }
  }

}

@pragma('vm:entry-point')
FutureOr<T?> runMapper<T extends SerializedModel>(
    List<dynamic> args,
    ) {
  final rawData = args[0] as Map<String, dynamic>?;
  final fromJsonFunction = args[1] as T Function(Map<String, dynamic>);

  try {
    if (rawData == null) return null;

    return fromJsonFunction(rawData);
  } catch (e, t) {
    Logger().e("Error mapping user", error: e, stackTrace: t);
  }
  return null;
}

@pragma('vm:entry-point')
FutureOr<List<T>> runMapperList<T extends SerializedModel>(
    List<dynamic> args,
    ) {
  final rawDataList = args[0] as List<Map<String, dynamic>>?;
  final fromJsonFunction = args[1] as T Function(Map<String, dynamic>);

  try {
    if (rawDataList == null) return [];
    return rawDataList.map((rawData) => fromJsonFunction(rawData)).toList();
  } catch (e, t) {
    Logger().e("Error mapping list of users", error: e, stackTrace: t);
  }
  return [];
}