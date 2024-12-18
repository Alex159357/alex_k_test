

import 'package:alex_k_test/src/features/data/models/serialized_model.dart';
import 'package:alex_k_test/src/features/domain/entities/map_pin_entity.dart';
import 'package:json_annotation/json_annotation.dart';
part 'map_pin_model.g.dart';

@JsonSerializable()
class MapPinModel extends MapPinEntity implements SerializedModel{
  const MapPinModel(super.latitude, super.longitude, super.label, super.comments, {super.id});


  factory MapPinModel.fromJson(Map<String, dynamic> json) => _$MapPinModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$MapPinModelToJson(this);

}