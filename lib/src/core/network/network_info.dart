
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

@immutable
class NetworkInfo{
  final Connectivity _connectivity;

  const NetworkInfo(this._connectivity);

  Future<bool> isConnected() async {
    final connection =  await _connectivity.checkConnectivity();
    return !connection.contains(ConnectivityResult.none);
  }

  Stream<bool> get connectionStream {
    return _connectivity.onConnectivityChanged.map(
          (result) => !result.contains(ConnectivityResult.none),
    );
  }

}