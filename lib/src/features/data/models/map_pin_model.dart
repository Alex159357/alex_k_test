import 'package:alex_k_test/src/features/data/models/serialized_model.dart';
import 'package:alex_k_test/src/features/domain/entities/map_pin_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'map_pin_model.g.dart';

@JsonSerializable()
class MapPinModel extends MapPinEntity implements SerializedModel {
  const MapPinModel(
    super.latitude,
    super.longitude,
    super.label,
    super.comments, {
    super.firebaseId,
    super.id,
    super.userId,
  });

  factory MapPinModel.fromJson(Map<String, dynamic> json) =>
      _$MapPinModelFromJson(json);

  @override
  Map<String, dynamic> toJson() {
    final json = _$MapPinModelToJson(this);

    // Remove id if it's null to let Firebase generate one
    if (json['id'] == null) {
      json.remove('id');
    }

    return json;
  }

  MapPinModel copyWith({
    int? id,
    String? firebaseId,
    double? latitude,
    double? longitude,
    String? label,
    String? comments,
    String? userId,
  }) {
    return MapPinModel(
      latitude ?? this.latitude,
      longitude ?? this.longitude,
      label ?? this.label,
      comments ?? this.comments,
      firebaseId:  firebaseId ?? this.firebaseId,
      id: id ?? this.id,
      userId: userId ?? this.userId,
    );
  }
}
