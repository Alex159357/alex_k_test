import 'package:alex_k_test/src/features/domain/entities/sync_queue_entity.dart';
import 'package:alex_k_test/src/features/domain/repositories/sync_queue_repository.dart';

class SyncQueueUseCase {
  final SyncQueueRepository _repository;

  SyncQueueUseCase(this._repository);

  Future<void> processQueueItems({
    required void Function(SyncQueueEntity) onItemProcessed,
    void Function(Object)? onError,
  }) async {
    await _repository.processQueueItems(
      onItemProcessed: onItemProcessed,
      onError: onError,
    );
  }
}
