import 'package:equatable/equatable.dart';

class MapPinEntity extends Equatable {
  final double? id;
  final double latitude;
  final double longitude;
  final String label;
  final String? comments;

  const MapPinEntity(this.latitude, this.longitude, this.label, this.comments, {this.id});

  @override
  List<Object?> get props => [latitude, longitude, label];
}
