import '../../domain/entities/question.dart';
import 'answer_model.dart';

class QuestionModel extends Question {
  const QuestionModel({
    required super.question,
    required super.type,
    required super.answers,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    var answersList = json['answers'] as List;
    List<AnswerModel> answers = answersList
        .map((answerJson) => AnswerModel.fromJson(answerJson))
        .toList();

    return QuestionModel(
      question: json['question'] as String,
      type: json['type'] as String,
      answers: answers,
    );
  }
}
