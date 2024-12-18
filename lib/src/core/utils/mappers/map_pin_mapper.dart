import 'package:alex_k_test/src/features/data/models/map_pin_model.dart';
import 'package:alex_k_test/src/features/domain/entities/map_pin_entity.dart';

class MapPinMapper {
  MapPinModel toModel(MapPinEntity entity) {
    return MapPinModel(
      entity.latitude,
      entity.longitude,
      entity.label,
      entity.comments,
      id: entity.id,
    );
  }

  MapPinEntity toEntity(MapPinModel model) {
    return MapPinEntity(
      model.latitude,
      model.longitude,
      model.label,
      model.comments,
      id: model.id,
    );
  }
}
