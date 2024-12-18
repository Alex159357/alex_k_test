import 'package:flutter/foundation.dart';

@immutable
class MapBoundsEntity {
  final double southWestLat;
  final double southWestLng;
  final double northEastLat;
  final double northEastLng;

  const MapBoundsEntity({
    required this.southWestLat,
    required this.southWestLng,
    required this.northEastLat,
    required this.northEastLng,
  });
}
