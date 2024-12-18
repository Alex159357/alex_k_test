// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'map_pin_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MapPinModel _$MapPinModelFromJson(Map<String, dynamic> json) => MapPinModel(
      (json['latitude'] as num).toDouble(),
      (json['longitude'] as num).toDouble(),
      json['label'] as String,
      json['comments'] as String?,
      id: (json['id'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$MapPinModelToJson(MapPinModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'label': instance.label,
      'comments': instance.comments,
    };
