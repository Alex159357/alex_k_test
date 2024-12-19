
class SyncState {
  bool isLoading;
  String? error;
  int queueCount;
  double syncProgress;

  SyncState({
    this.isLoading = false,
    this.error,
    this.queueCount = 0,
    this.syncProgress = 0.0,
  });

  SyncState init() {
    return SyncState();
  }

  bool get syncAvailable => !isLoading && queueCount >0;


  SyncState copyWith({
    bool? isLoading,
    String? error,
    int? unSyncedCount,
    int? queueCount,
    double? syncProgress,
  }) {
    return SyncState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      queueCount: unSyncedCount ?? this.queueCount,
      syncProgress: syncProgress ?? this.syncProgress,
    );
  }
}
