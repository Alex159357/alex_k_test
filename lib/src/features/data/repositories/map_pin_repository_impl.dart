import 'package:alex_k_test/src/core/failure/failure.dart';
import 'package:alex_k_test/src/core/utils/mappers/map_pin_mapper.dart';
import 'package:alex_k_test/src/features/data/datasources/local/local_data_sourse.dart';
import 'package:alex_k_test/src/features/domain/entities/map_pin_entity.dart';
import 'package:alex_k_test/src/features/domain/repositories/map_pins_repository.dart';
import 'package:either_dart/src/either.dart';

class MapPinRepositoryImpl implements MapPinsRepository {
  final LocalDataSource _localDataSource;
  final MapPinMapper _mapPinMapper;

  MapPinRepositoryImpl(this._localDataSource, this._mapPinMapper);

  @override
  Future<Either<Failure, List<MapPinEntity>>> getAllPins() async {
    final mapPins = await _localDataSource.readMapPins();
    if (mapPins != null) {
      return Right(mapPins);
    } else {
      return Left(FailureHandler("MapPinsRepository")
          .logError("getAllPins", "Error to read Map Pins"));
    }
  }

  @override
  Stream<Either<Failure, List<MapPinEntity>>> observeAllPins() async* {
    yield* _localDataSource.observeMapPins().asyncMap((e) {
      if (e != null) {
        return Right(e);
      } else {
        return Left(FailureHandler("MapPinsRepository")
            .logError("observeAllPins", "Error observe pins"));
      }
    });
  }

  @override
  Future<Either<Failure, List<MapPinEntity>>> savePin(MapPinEntity pin) async {
    final model = _mapPinMapper.toModel(pin);
    final result = await _localDataSource.saveMapPin(model);
    if (result != null) {
      return Right(result);
    } else {
      return Left(FailureHandler("MapPinsRepository")
          .logError("savePin", "Error save pin"));
    }
  }

  @override
  Future<Either<Failure, List<MapPinEntity>>> updatePin(
      MapPinEntity pin) async {
    final model = _mapPinMapper.toModel(pin);

    // First try to update the pin
    final updateResult = await _localDataSource.updateMapPin(model);
    if (!updateResult) {
      return Left(FailureHandler("MapPinsRepository")
          .logError("updatePin", "Error updating pin"));
    }

    // If update successful, return all pins
    final allPins = await _localDataSource.readMapPins();
    if (allPins != null) {
      return Right(allPins);
    } else {
      return Left(FailureHandler("MapPinsRepository")
          .logError("updatePin", "Error reading pins after update"));
    }
  }
}
