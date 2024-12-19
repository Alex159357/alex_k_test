import 'package:equatable/equatable.dart';

class MapPinEntity extends Equatable {
  final int? id;
  final String? firebaseId;
  final double latitude;
  final double longitude;
  final String label;
  final String? comments;
  final String? userId;

  const MapPinEntity(
    this.latitude,
    this.longitude,
    this.label,
    this.comments, {
    this.firebaseId,
    this.id,
    this.userId,
  });

  @override
  List<Object?> get props => [latitude, longitude, label];
}
