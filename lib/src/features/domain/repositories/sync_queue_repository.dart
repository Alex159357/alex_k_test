import 'package:alex_k_test/src/features/domain/entities/sync_queue_entity.dart';

abstract class SyncQueueRepository {
  Future<bool> addToQueue(SyncQueueEntity item);
  Future<List<SyncQueueEntity>> getAllQueueItems();
  Future<SyncQueueEntity?> getQueueItemById(int id);
  Future<bool> updateQueueItem(SyncQueueEntity item);
  Future<bool> deleteQueueItem(int id);

  /// Observe the number of items in the sync queue
  Stream<int> observeQueueCount();

  /// Process all items in the sync queue using an isolate
  ///
  /// [onProgressUpdate] is called with the current progress percentage (0-100)
  /// [onItemProcessed] is called for each item in the queue
  /// [onError] is called if an error occurs during processing
  /// [onComplete] is called when all items have been processed successfully
  Future<void> processQueueItems({
    required void Function(double) onProgressUpdate,
    required void Function(SyncQueueEntity) onItemProcessed,
    void Function(Object)? onError,
    void Function()? onComplete,
  });
}
