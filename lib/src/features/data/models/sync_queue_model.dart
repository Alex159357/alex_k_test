import 'package:alex_k_test/src/features/data/models/serialized_model.dart';
import 'package:alex_k_test/src/features/domain/entities/sync_queue_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'sync_queue_model.g.dart';

@JsonSerializable()
class SyncQueueModel extends SyncQueueEntity implements SerializedModel {
  SyncQueueModel({
    super.id,
    required super.type,
    required super.data,
    super.createdAt,
  });

  factory SyncQueueModel.fromJson(Map<String, dynamic> json) =>
      _$SyncQueueModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SyncQueueModelToJson(this);
}
