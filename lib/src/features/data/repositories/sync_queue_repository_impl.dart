import 'package:alex_k_test/src/core/database/data_base_providers/sync_queue_database.dart';
import 'package:alex_k_test/src/core/utils/isolate/queue_processor.dart';
import 'package:alex_k_test/src/features/data/models/sync_queue_model.dart';
import 'package:alex_k_test/src/features/domain/entities/sync_queue_entity.dart';
import 'package:alex_k_test/src/features/domain/repositories/sync_queue_repository.dart';

class SyncQueueRepositoryImpl implements SyncQueueRepository {
  final SyncQueueDatabase _database;

  SyncQueueRepositoryImpl(this._database);

  @override
  Future<bool> addToQueue(SyncQueueEntity item) async {
    final model = SyncQueueModel(
      id: item.id,
      type: item.type,
      data: item.data,
      createdAt: item.createdAt,
      isSynced: item.isSynced,
      error: item.error,
    );
    return await _database.insertQueueItem(model.toJson());
  }

  @override
  Future<List<SyncQueueEntity>> getAllQueueItems() async {
    final items = await _database.getAllQueueItems();
    return items.map((item) => SyncQueueModel.fromJson(item)).toList();
  }

  @override
  Future<SyncQueueEntity?> getQueueItemById(int id) async {
    final item = await _database.getQueueItemById(id);
    if (item != null) {
      return SyncQueueModel.fromJson(item);
    }
    return null;
  }

  @override
  Future<bool> updateQueueItem(SyncQueueEntity item) async {
    if (item.id == null) return false;
    final model = SyncQueueModel(
      id: item.id,
      type: item.type,
      data: item.data,
      createdAt: item.createdAt,
      isSynced: item.isSynced,
      error: item.error,
    );
    final result = await _database.updateQueueItem(item.id!, model.toJson());
    return result > 0;
  }

  @override
  Future<bool> deleteQueueItem(int id) async {
    return await _database.deleteQueueItem(id);
  }

  @override
  Future<void> processQueueItems({
    required void Function(SyncQueueEntity) onItemProcessed,
    void Function(Object)? onError,
  }) async {
    final items = await getAllQueueItems();
    await QueueProcessor.processWithIsolate<SyncQueueEntity>(
      items: items,
      onItemProcessed: onItemProcessed,
      onError: onError,
    );
  }
}
