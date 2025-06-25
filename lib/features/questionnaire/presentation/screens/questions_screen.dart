import 'dart:math';

import 'package:flutter/material.dart';

import '../../../results/presentation/screens/results_screen.dart';
import '../../data/repositories/question_repository_impl.dart';
import '../../domain/entities/answer.dart';
import '../../domain/entities/question.dart';
import '../../domain/repositories/question_repository.dart';

class QuestionsScreen extends StatefulWidget {
  const QuestionsScreen({super.key});

  @override
  _QuestionsScreenState createState() => _QuestionsScreenState();
}

class _QuestionsScreenState extends State<QuestionsScreen> {
  final QuestionRepository _questionRepository = QuestionRepositoryImpl();

  List<Question> _unseenQuestions = [];
  Question? _currentQuestion;
  List<Answer> _shuffledAnswers = [];
  Map<String, int> _answers = {};
  int _totalQuestions = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    final allQuestions = await _questionRepository.getQuestions();
    final answers = <String, int>{};
    for (var q in allQuestions) {
      answers[q.type] = 0;
    }

    final random = Random();
    final firstQuestion = allQuestions[random.nextInt(allQuestions.length)];

    final unseen = List<Question>.from(allQuestions);
    unseen.remove(firstQuestion);
    unseen.shuffle(random);

    final shuffled = List<Answer>.from(firstQuestion.answers);
    shuffled.shuffle(random);

    setState(() {
      _unseenQuestions = unseen;
      _answers = answers;
      _currentQuestion = firstQuestion;
      _shuffledAnswers = shuffled;
      _totalQuestions = allQuestions.length;
      _isLoading = false;
    });
  }

  void _answerQuestion(Answer answer) {
    if (_currentQuestion == null) return;

    if (answer.isTraumaSign) {
      final String currentType = _currentQuestion!.type;
      setState(() {
        _answers[currentType] = (_answers[currentType] ?? 0) + 1;
      });
    }

    if (_unseenQuestions.isEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResultsScreen(answers: _answers),
        ),
      );
    } else {
      _showNextQuestion();
    }
  }

  void _showNextQuestion() {
    final String lastCategory = _currentQuestion!.type;

    final nextQuestionIndex =
        _unseenQuestions.indexWhere((q) => q.type != lastCategory);

    Question nextQuestion;
    if (nextQuestionIndex != -1) {
      nextQuestion = _unseenQuestions.removeAt(nextQuestionIndex);
    } else {
      nextQuestion = _unseenQuestions.removeAt(0);
    }

    final shuffled = List<Answer>.from(nextQuestion.answers);
    shuffled.shuffle();

    setState(() {
      _currentQuestion = nextQuestion;
      _shuffledAnswers = shuffled;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Загрузка...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final question = _currentQuestion;

    return Scaffold(
      appBar: AppBar(title: const Text('Анкета')),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  question?.question ?? 'Нет вопросов',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min, // Чтобы колонка не занимала все доступное место
              children: _shuffledAnswers.map((answer) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: ElevatedButton(
                    onPressed: () => _answerQuestion(answer),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    child: Text(
                      answer.text,
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: (_totalQuestions - _unseenQuestions.length) /
                      _totalQuestions,
                ),
                const SizedBox(height: 8),
                Text(
                  '${_totalQuestions - _unseenQuestions.length} / $_totalQuestions',
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
