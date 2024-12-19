// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_queue_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SyncQueueModel _$SyncQueueModelFromJson(Map<String, dynamic> json) =>
    SyncQueueModel(
      id: (json['id'] as num?)?.toInt(),
      type: json['type'] as String,
      data: json['data'] as String,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$SyncQueueModelToJson(SyncQueueModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'data': instance.data,
      'createdAt': instance.createdAt.toIso8601String(),
    };
