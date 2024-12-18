import 'package:alex_k_test/src/features/domain/entities/sync_queue_entity.dart';

abstract class SyncQueueRepository {
  Future<bool> addToQueue(SyncQueueEntity item);
  Future<List<SyncQueueEntity>> getAllQueueItems();
  Future<SyncQueueEntity?> getQueueItemById(int id);
  Future<bool> updateQueueItem(SyncQueueEntity item);
  Future<bool> deleteQueueItem(int id);

  /// Process all items in the sync queue using an isolate
  ///
  /// [onItemProcessed] is called for each item in the queue
  /// [onError] is called if an error occurs during processing
  Future<void> processQueueItems({
    required void Function(SyncQueueEntity) onItemProcessed,
    void Function(Object)? onError,
  });
}
