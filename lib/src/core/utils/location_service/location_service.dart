

import 'dart:async';

import 'package:alex_k_test/src/features/data/models/user_position_model.dart';
import 'package:alex_k_test/src/features/domain/entities/user_position_entity.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {

  Stream<UserPositionEntity> observe() async* {
    final positionStream = Geolocator.getPositionStream();

    await for (final position in positionStream) {

      yield UserPositionModel(position.latitude, position.longitude, position.timestamp.millisecondsSinceEpoch);
    }
  }

}