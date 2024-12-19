import 'package:flutter/foundation.dart';

@immutable
sealed class SyncEvent {
  const SyncEvent();
}

class InitEvent extends SyncEvent {
  const InitEvent();
}

class RunSync extends SyncEvent {
  const RunSync();
}

class OnSyncProcessorEvent extends SyncEvent {
  final double percentage;
  const OnSyncProcessorEvent(this.percentage);
}

class OnSyncItemCountChanged extends SyncEvent {
  final int count;
  const OnSyncItemCountChanged(this.count);
}

class OnSyncError extends SyncEvent {
  final String error;
  const OnSyncError(this.error);
}

class OnSyncComplete extends SyncEvent {
  const OnSyncComplete();
}
