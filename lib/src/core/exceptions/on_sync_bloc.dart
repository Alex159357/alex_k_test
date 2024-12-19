import 'package:alex_k_test/src/features/presentation/blocs/sync/bloc.dart';
import 'package:alex_k_test/src/features/presentation/blocs/sync/event.dart';

extension OnSyncBloc on SyncBloc {
  void init() => add(const InitEvent());
  void runSync() => add(const RunSync());
}
