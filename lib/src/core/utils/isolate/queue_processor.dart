import 'dart:isolate';

import 'package:alex_k_test/src/features/domain/entities/sync_queue_entity.dart';

class QueueProcessor {
  static Future<void> processWithIsolate<T>({
    required List<T> items,
    required void Function(T) onItemProcessed,
    void Function(Object)? onError,
  }) async {
    try {
      final receivePort = ReceivePort();
      await Isolate.spawn(
        _processItems,
        _IsolateData(
          items: items,
          sendPort: receivePort.sendPort,
        ),
      );

      await for (final dynamic message in receivePort) {
        if (message is T) {
          onItemProcessed(message);
        } else if (message is String && message == 'DONE') {
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
  static Future<void> _processItems<T>(_IsolateData<T> data) async {
    try {
      for (final item in data.items) {
        // Add delay to prevent overwhelming the main thread
        await Future.delayed(const Duration(milliseconds: 100));
        data.sendPort.send(item);
      }
      data.sendPort.send('DONE');
    } catch (e) {
      data.sendPort.send(Exception('Error processing items: $e'));
    }
  }
}

class _IsolateData<T> {
  final List<T> items;
  final SendPort sendPort;

  const _IsolateData({
    required this.items,
    required this.sendPort,
  });
}
