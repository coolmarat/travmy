import 'dart:convert';
import 'package:flutter/services.dart';
import '../../domain/entities/impostor_type.dart';
import '../../domain/repositories/impostor_type_repository.dart';
import '../models/impostor_type_model.dart';

class ImpostorTypeRepositoryImpl implements ImpostorTypeRepository {
  @override
  Future<List<ImpostorType>> getImpostorTypes() async {
    final String jsonString = await rootBundle.loadString('assets/types.json');
    final List<dynamic> jsonData = json.decode(jsonString);
    return jsonData.map((item) => ImpostorTypeModel.fromJson(item)).toList();
  }
}
