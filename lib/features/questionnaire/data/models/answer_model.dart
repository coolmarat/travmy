import '../../domain/entities/answer.dart';

class AnswerModel extends Answer {
  const AnswerModel({required super.text, required super.isTraumaSign});

  factory AnswerModel.fromJson(Map<String, dynamic> json) {
    return AnswerModel(
      text: json['text'] as String,
      isTraumaSign: json['isTraumaSign'] as bool,
    );
  }
}
