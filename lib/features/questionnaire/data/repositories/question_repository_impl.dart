import 'dart:convert';
import 'package:flutter/services.dart';
import '../../domain/entities/question.dart';
import '../../domain/repositories/question_repository.dart';
import '../models/question_model.dart';

class QuestionRepositoryImpl implements QuestionRepository {
  @override
  Future<List<Question>> getQuestions() async {
    final String jsonString =
        await rootBundle.loadString('assets/questions.json');
    final List<dynamic> jsonData = json.decode(jsonString);
    return jsonData.map((q) => QuestionModel.fromJson(q)).toList();
  }
}
