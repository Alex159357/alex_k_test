import 'dart:async';

import 'package:alex_k_test/src/features/domain/usecases/network_usecase.dart';
import 'package:alex_k_test/src/features/domain/usecases/sync_queue_usecase.dart';
import 'package:bloc/bloc.dart';

import 'event.dart';
import 'state.dart';

class SyncBloc extends Bloc<SyncEvent, SyncState> {
  SyncBloc(this._syncQueueUseCase, this._networkUseCase) : super(SyncState().init()) {
    on<InitEvent>(_init);
    on<OnSyncItemCountChanged>(_onSyncItemCountChanged);
    on<RunSync>(_runtSync);
    on<OnSyncComplete>(_onSyncComplete);
    on<OnSyncError>(_onSyncError);
    on<OnSyncProcessorEvent>(_onSyncProcessorEvent);
  }

  final SyncQueueUseCase _syncQueueUseCase;
  final NetworkUseCase _networkUseCase;
  late StreamSubscription _connectionStateSubscription;
  late StreamSubscription _syncSubscription;

  void _init(InitEvent event, Emitter<SyncState> emit) async {
    _syncSubscription = _syncQueueUseCase.observeQueueCount().listen((e) {
      add(OnSyncItemCountChanged(e));
    });
    _connectionStateSubscription = _networkUseCase.observeConnectionState().listen((e){
      if(e && !state.isLoading) {
        add(const RunSync());
      }
    });
    emit(state.copyWith());
  }

  void _onSyncItemCountChanged(
      OnSyncItemCountChanged event, Emitter<SyncState> emit) {
    emit(state.copyWith(unSyncedCount: event.count));
  }

  void _runtSync(RunSync event, Emitter<SyncState> emit) {
    emit(state.copyWith(isLoading: true));
    _runSyncProcess();
  }

  void _runSyncProcess() {

    _syncQueueUseCase.processQueueItems(
        onProgressUpdate: (progress) {
          add(OnSyncProcessorEvent(progress));
        },
        onItemProcessed: (SyncQueueEntity) {},
        onComplete: () {
          add(const OnSyncComplete());
        },
        onError: (v) {
          add(const OnSyncComplete());
        });
  }

  void _onSyncProcessorEvent(
      OnSyncProcessorEvent event, Emitter<SyncState> emit) {
    emit(state.copyWith(syncProgress: event.percentage));
  }

  void _onSyncComplete(OnSyncComplete event, Emitter<SyncState> emit) {
    emit(state.copyWith(isLoading: false));
  }

  void _onSyncError(OnSyncError event, Emitter<SyncState> emit) {
    emit(state.copyWith(isLoading: false));
  }

  @override
  Future<void> close() async {
    await _connectionStateSubscription.cancel();
    await _syncSubscription.cancel();
    super.close();
  }

}
