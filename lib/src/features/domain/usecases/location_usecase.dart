

import 'package:alex_k_test/src/core/utils/location_service/location_service.dart';
import 'package:alex_k_test/src/features/domain/entities/user_position_entity.dart';

class LocationUseCase{
  final LocationService _locationService;

  LocationUseCase(this._locationService);

  Stream<UserPositionEntity> observeLocation() => _locationService.observe();


}