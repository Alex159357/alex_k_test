import 'package:alex_k_test/src/features/domain/entities/sync_queue_entity.dart';
import 'package:alex_k_test/src/features/domain/repositories/sync_queue_repository.dart';
import 'package:logger/logger.dart';

class SyncQueueUseCase {
  final SyncQueueRepository _repository;
  final Logger _logger = Logger();

  SyncQueueUseCase(this._repository);

  Stream<int> observeQueueCount() {
    try {
      return _repository.observeQueueCount();
    } catch (e, stackTrace) {
      _logger.e('Failed to observe queue count',
          error: e, stackTrace: stackTrace);
      return Stream.value(0);
    }
  }

  Future<bool> addToQueue(SyncQueueEntity item) async {
    try {
      return await _repository.addToQueue(item);
    } catch (e, stackTrace) {
      _logger.e('Failed to add item to queue',
          error: e, stackTrace: stackTrace);
      return false;
    }
  }

  Future<List<SyncQueueEntity>> getAllQueueItems() async {
    try {
      return await _repository.getAllQueueItems();
    } catch (e, stackTrace) {
      _logger.e('Failed to get queue items', error: e, stackTrace: stackTrace);
      return [];
    }
  }

  Future<SyncQueueEntity?> getQueueItemById(int id) async {
    try {
      return await _repository.getQueueItemById(id);
    } catch (e, stackTrace) {
      _logger.e('Failed to get queue item by id',
          error: e, stackTrace: stackTrace);
      return null;
    }
  }

  Future<bool> updateQueueItem(SyncQueueEntity item) async {
    try {
      if (item.id == null) {
        _logger.w('Attempted to update queue item without id');
        return false;
      }
      return await _repository.updateQueueItem(item);
    } catch (e, stackTrace) {
      _logger.e('Failed to update queue item',
          error: e, stackTrace: stackTrace);
      return false;
    }
  }

  Future<bool> deleteQueueItem(int id) async {
    try {
      return await _repository.deleteQueueItem(id);
    } catch (e, stackTrace) {
      _logger.e('Failed to delete queue item',
          error: e, stackTrace: stackTrace);
      return false;
    }
  }

  Future<void> processQueueItems({
    required void Function(double) onProgressUpdate,
    required void Function(SyncQueueEntity) onItemProcessed,
    void Function(Object)? onError,
    void Function()? onComplete,
  }) async {
    try {
      await _repository.processQueueItems(
        onProgressUpdate: onProgressUpdate,
        onItemProcessed: onItemProcessed,
        onError: (error) {
          _logger.e('Error processing queue item', error: error);
          onError?.call(error);
        },
        onComplete: () {
          _logger.i('Queue processing completed');
          onComplete?.call();
        },
      );
    } catch (e, stackTrace) {
      _logger.e('Failed to process queue items',
          error: e, stackTrace: stackTrace);
      onError?.call(e);
    }
  }
}
