

import 'package:equatable/equatable.dart';

class UserPositionEntity extends Equatable{
  final double lat;
  final double lng;
  final int timeStamp;

  const UserPositionEntity(this.lat, this.lng, this.timeStamp);

  @override
  List<Object?> get props => [timeStamp];
}