

import 'package:alex_k_test/src/features/data/models/serialized_model.dart';
import 'package:alex_k_test/src/features/domain/entities/user_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel extends UserEntity implements SerializedModel{

  const UserModel(super.id, super.userName);

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$UserModelToJson(this);

}