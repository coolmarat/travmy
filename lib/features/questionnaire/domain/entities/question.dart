import 'answer.dart';

class Question {
  final String question;
  final String type;
  final List<Answer> answers;

  const Question({
    required this.question,
    required this.type,
    required this.answers,
  });
}
