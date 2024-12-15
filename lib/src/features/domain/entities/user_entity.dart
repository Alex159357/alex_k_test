import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final int id;
  final String userName;

  const UserEntity(this.id, this.userName);

  bool get isDemo => id < 0;

  @override
  List<Object?> get props => [id, userName];
}
