import 'package:equatable/equatable.dart';

class SyncQueueEntity extends Equatable {
  final int? id;
  final String type;
  final String data;
  final DateTime createdAt;
  final bool isSynced;
  final String? error;

  const SyncQueueEntity({
    this.id,
    required this.type,
    required this.data,
    required this.createdAt,
    this.isSynced = false,
    this.error,
  });

  @override
  List<Object?> get props => [id, type, data, createdAt, isSynced, error];
}
