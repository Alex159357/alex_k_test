import 'dart:convert';
import 'dart:isolate';

import 'package:alex_k_test/src/features/data/models/map_pin_model.dart';
import 'package:alex_k_test/src/features/domain/entities/sync_queue_entity.dart';

class QueueProcessor {
  static Future<void> processQueueWithIsolate({
    required List<SyncQueueEntity> items,
    required List<MapPinModel> downloadedPins,
    required void Function(double) onProgressUpdate,
    required void Function(SyncQueueEntity) onItemProcessed,
    void Function(Object)? onError,
    void Function()? onComplete,
  }) async {
    try {
      final receivePort = ReceivePort();
      await Isolate.spawn(
        _processQueueItems,
        _IsolateData(
          items: items,
          downloadedPins: downloadedPins,
          sendPort: receivePort.sendPort,
        ),
      );

      await for (final dynamic message in receivePort) {
        if (message is double) {
          onProgressUpdate(message);
        } else if (message is SyncQueueEntity) {
          onItemProcessed(message);
        } else if (message is String && message == 'DONE') {
          onComplete?.call();
          receivePort.close();
          break;
        } else if (message is Exception) {
          onError?.call(message);
          receivePort.close();
          break;
        }
      }
    } catch (e) {
      onError?.call(e);
    }
  }

  @pragma('vm:entry-point')
  static Future<void> _processQueueItems(_IsolateData data) async {
    try {
      final items = data.items;
      final totalItems = items.length;

      if (totalItems == 0) {
        data.sendPort.send('DONE');
        return;
      }

      for (var i = 0; i < totalItems; i++) {
        try {
          final item = items[i];
          final progress = ((i + 1) / totalItems) * 100;

          // Process the queue item
          final MapPinModel? fromSync =
              MapPinModel.fromJson(jsonDecode(item.data));
          if (fromSync != null) {
            // Send progress update
            data.sendPort.send(progress);
            // Send processed item
            data.sendPort.send(item);
          }

          // Add small delay to prevent overwhelming the main thread
          await Future.delayed(const Duration(milliseconds: 100));
        } catch (e) {
          data.sendPort.send(Exception('Error processing item: $e'));
        }
      }

      data.sendPort.send('DONE');
    } catch (e) {
      data.sendPort.send(Exception('Error processing items: $e'));
    }
  }
}

class _IsolateData {
  final List<SyncQueueEntity> items;
  final List<MapPinModel> downloadedPins;
  final SendPort sendPort;

  const _IsolateData({
    required this.items,
    required this.downloadedPins,
    required this.sendPort,
  });
}
