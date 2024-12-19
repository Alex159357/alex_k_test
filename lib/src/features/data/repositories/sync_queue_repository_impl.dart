import 'dart:convert';

import 'package:alex_k_test/src/core/database/data_base_providers/sync_queue_database.dart';
import 'package:alex_k_test/src/core/utils/isolate/queue_processor.dart';
import 'package:alex_k_test/src/core/utils/mappers/universal_mapper.dart';
import 'package:alex_k_test/src/features/data/datasources/local/local_data_sourse.dart';
import 'package:alex_k_test/src/features/data/datasources/remote/remote_data_source.dart';
import 'package:alex_k_test/src/features/data/models/map_pin_model.dart';
import 'package:alex_k_test/src/features/data/models/sync_queue_model.dart';
import 'package:alex_k_test/src/features/domain/entities/sync_queue_entity.dart';
import 'package:alex_k_test/src/features/domain/repositories/sync_queue_repository.dart';
import 'package:logger/logger.dart';

class SyncQueueRepositoryImpl implements SyncQueueRepository {
  final SyncQueueDatabase _database;
  final Logger _logger = Logger();
  final RemoteDataSource _remoteDataSource;
  final UniversalMapper _universalMapper;
  final LocalDataSource _localDataSource;

  SyncQueueRepositoryImpl(
    this._database,
    this._remoteDataSource,
    this._universalMapper,
    this._localDataSource,
  );

  @override
  Future<bool> addToQueue(SyncQueueEntity item) async {
    try {
      final model = SyncQueueModel(
        id: item.id,
        type: item.type,
        data: item.data,
        createdAt: item.createdAt,
      );
      return await _database.insertQueueItem(model.toJson());
    } catch (e) {
      _logger.e('Failed to add item to queue', error: e);
      return false;
    }
  }

  @override
  Future<bool> deleteQueueItem(int id) async {
    try {
      return await _database.deleteQueueItem(id);
    } catch (e) {
      _logger.e('Failed to delete queue item', error: e);
      return false;
    }
  }

  @override
  Future<List<SyncQueueEntity>> getAllQueueItems() async {
    try {
      final rawItems = await _database.getAllQueueItems();
      return rawItems.map((item) => SyncQueueModel.fromJson(item)).toList();
    } catch (e) {
      _logger.e('Failed to get all queue items', error: e);
      return [];
    }
  }

  @override
  Future<SyncQueueEntity?> getQueueItemById(int id) async {
    try {
      final raw = await _database.getQueueItemById(id);
      return raw != null ? SyncQueueModel.fromJson(raw) : null;
    } catch (e) {
      _logger.e('Failed to get queue item by id', error: e);
      return null;
    }
  }

  @override
  Stream<int> observeQueueCount() {
    return _database.observeQueueCount();
  }

  Future<void> _handleQueueItem(
    SyncQueueEntity item,
    void Function(Object)? onError,
  ) async {
    print("SavingToDb -> START");
    try {
      final MapPinModel? fromSync = await _universalMapper.tryMap<MapPinModel>(
          jsonDecode(item.data), MapPinModel.fromJson);

      if (fromSync != null) {
        if (item.type == "create") {
          await _handleCreatePin(fromSync, item, onError);
        } else if (item.type == "update") {
          await _handleUpdatePin(fromSync, item);
        }
      }
    } catch (e) {
      _logger.e('Error processing queue item', error: e);
      onError?.call(e);
    }
  }

  Future<void> _handleCreatePin(
    MapPinModel pin,
    SyncQueueEntity item,
    void Function(Object)? onError,
  ) async {
    final firebaseId = await _remoteDataSource.uploadMapPin(pin);
    if (firebaseId != null) {
      final updatedPin = pin.copyWith(firebaseId: firebaseId);
      await _remoteDataSource.updateMapPin(firebaseId, updatedPin);

      final localUpdateResult = await _localDataSource.updateMapPin(updatedPin);
      if (!localUpdateResult) {
        _logger.e('Failed to update local pin with firebaseId');
        return;
      }

      await deleteQueueItem(item.id!);
    }
  }

  Future<void> _handleUpdatePin(MapPinModel pin, SyncQueueEntity item) async {
    if (pin.firebaseId != null) {
      final success =
          await _remoteDataSource.updateMapPin(pin.firebaseId!, pin);
      if (success) {
        await deleteQueueItem(item.id!);
      }
    } else {
      _logger.e('Cannot update pin without firebaseId');
    }
  }

  Future<List<MapPinModel>> _downloadPinsFromFirebase() async {
    _logger.i('Fetching pins from Firebase');
    try {
      final remotePins = await _remoteDataSource.fetchMapPins();
      return remotePins;
    } catch (e) {
      _logger.e('Error downloading pins from Firebase', error: e);
      rethrow;
    }
  }

  Future<void> _updateLocalPinsWithRemote(
    List<MapPinModel> remotePins,
    void Function(Object)? onError,
  ) async {
    for (final remotePin in remotePins) {
      try {
        final localPins = await _localDataSource.readMapPins() ?? [];
        final localPin = localPins.firstWhere(
          (pin) => pin.firebaseId == remotePin.firebaseId,
          orElse: () => remotePin,
        );
        await _localDataSource.saveMapPin(remotePin.copyWith(id: DateTime.now().millisecondsSinceEpoch));
        // if (localPin.firebaseId == remotePin.firebaseId) {
        //   await _localDataSource.updateMapPin(remotePin);
        // } else {
        //   final pinWithNewId = remotePin.copyWith(
        //     id: DateTime.now().millisecondsSinceEpoch,
        //   );
        //   await _localDataSource.saveMapPin(pinWithNewId);
        // }
      } catch (e) {
        _logger.e('Error syncing remote pin locally', error: e);
        onError?.call(e);
      }
    }
  }

  Future<void> _processQueueItems(
    List<SyncQueueEntity> items,
    void Function(double) onProgressUpdate,
    void Function(SyncQueueEntity) onItemProcessed,
    void Function(Object)? onError,
  ) async {
    await QueueProcessor.processQueueWithIsolate(
      items: items,
      downloadedPins: [],
      onProgressUpdate: onProgressUpdate,
      onItemProcessed: (item) async {
        await _handleQueueItem(item, onError);
        onItemProcessed(item);
      },
      onError: (e) {
        _logger.e('Failed to process queue items', error: e);
        onError?.call(e);
      },
      onComplete: () async {
        _logger.i('Queue processing completed');
      },
    );
  }

  @override
  Future<void> processQueueItems({
    required void Function(double) onProgressUpdate,
    required void Function(SyncQueueEntity) onItemProcessed,
    void Function(Object)? onError,
    void Function()? onComplete,
  }) async {
    try {
      final items = await getAllQueueItems();
      if (items.isNotEmpty) {
        _logger.i('Processing queue items for upload');
        await _processQueueItems(
          items,
          onProgressUpdate,
          onItemProcessed,
          onError,
        );
      }

      // After queue processing (or if no items), download from Firebase
      try {
        final remotePins = await _downloadPinsFromFirebase();
        await _updateLocalPinsWithRemote(remotePins, onError);
        onComplete?.call();
      } catch (e) {
        onError?.call(e);
      }
    } catch (e, stackTrace) {
      _logger.e('Failed to process queue items',
          error: e, stackTrace: stackTrace);
      onError?.call(e);
    }
  }

  @override
  Future<bool> updateQueueItem(SyncQueueEntity item) async {
    try {
      if (item.id == null) {
        _logger.e('Cannot update queue item without id');
        return false;
      }
      final model = SyncQueueModel(
        id: item.id,
        type: item.type,
        data: item.data,
        createdAt: item.createdAt,
      );
      final result = await _database.updateQueueItem(item.id!, model.toJson());
      return result > 0;
    } catch (e) {
      _logger.e('Failed to update queue item', error: e);
      return false;
    }
  }
}
