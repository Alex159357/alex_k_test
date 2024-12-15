

import 'package:alex_k_test/src/features/domain/entities/user_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel extends UserEntity{

  const UserModel(super.id, super.userName);

  factory UserModel.getDemo() => const UserModel(-1, "John Dou");

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserModelToJson(this);

}