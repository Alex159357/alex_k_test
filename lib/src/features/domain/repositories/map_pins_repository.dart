
import 'package:alex_k_test/src/core/failure/failure.dart';
import 'package:alex_k_test/src/features/domain/entities/map_pin_entity.dart';
import 'package:either_dart/either.dart';
import 'package:flutter/foundation.dart';

@immutable
abstract interface class MapPinsRepository{

  Future<Either<Failure, List<MapPinEntity>>> getAllPins();

  Stream<Either<Failure, List<MapPinEntity>>> observeAllPins();

  Future<Either<Failure, List<MapPinEntity>>> savePin(MapPinEntity pin);

  Future<Either<Failure, List<MapPinEntity>>> updatePin(MapPinEntity pin);

}