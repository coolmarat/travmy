import '../../domain/entities/impostor_type.dart';

class ImpostorTypeModel extends ImpostorType {
  const ImpostorTypeModel({required super.type, required super.description});

  factory ImpostorTypeModel.fromJson(Map<String, dynamic> json) {
    return ImpostorTypeModel(
      type: json['type'] as String,
      description: json['description'] as String,
    );
  }
}
