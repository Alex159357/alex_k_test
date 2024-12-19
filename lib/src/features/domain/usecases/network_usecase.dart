

import 'package:alex_k_test/src/core/network/network_info.dart';

class NetworkUseCase{
  final NetworkInfo _networkInfo;

  NetworkUseCase(this._networkInfo);

  Stream<bool> observeConnectionState() => _networkInfo.connectionStream;

}