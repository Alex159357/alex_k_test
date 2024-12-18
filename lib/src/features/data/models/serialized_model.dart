

abstract interface class SerializedModel{

  factory SerializedModel.fromJson(Map<String, dynamic> json) {
    throw UnimplementedError('fromJson not found');
  }
  Map<String, dynamic> toJson();

}