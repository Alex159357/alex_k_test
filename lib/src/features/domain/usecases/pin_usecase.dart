

import 'package:alex_k_test/src/core/failure/failure.dart';
import 'package:alex_k_test/src/features/domain/entities/map_pin_entity.dart';
import 'package:alex_k_test/src/features/domain/repositories/map_pins_repository.dart';
import 'package:either_dart/either.dart';

class PinUseCase{
  final MapPinsRepository _repository;


  PinUseCase(this._repository);

  Future<Either<Failure, List<MapPinEntity>>> getAllPins() async => await _repository.getAllPins();

  Stream<Either<Failure, List<MapPinEntity>>> observeAllPins() => _repository.observeAllPins();

  Future<Either<Failure, List<MapPinEntity>>> savePin(MapPinEntity pin) async => await _repository.savePin(pin);

  Future<Either<Failure, List<MapPinEntity>>> updatePin(MapPinEntity pin) async => _repository.updatePin(pin);

}