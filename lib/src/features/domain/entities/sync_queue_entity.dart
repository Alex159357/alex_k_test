import 'package:equatable/equatable.dart';

class SyncQueueEntity extends Equatable {
  final int? id;
  final String type;
  final String data;
  final DateTime createdAt;

  SyncQueueEntity({
    this.id,
    required this.type,
    required this.data,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  SyncQueueEntity copyWith({
    int? id,
    String? type,
    String? data,
    DateTime? createdAt,
  }) {
    return SyncQueueEntity(
      id: id ?? this.id,
      type: type ?? this.type,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, type, data, createdAt];
}
