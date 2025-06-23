import 'dart:convert';
import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Model for a question
class Question {
  final String question;
  final String type;

  Question({required this.question, required this.type});

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      question: json['question'] as String,
      type: json['type'] as String,
    );
  }
}

void main() {
  runApp(ImpostorSyndromeApp());
}

class ImpostorSyndromeApp extends StatelessWidget {
  const ImpostorSyndromeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: QuestionsScreen(),
    );
  }
}

class QuestionsScreen extends StatefulWidget {
  const QuestionsScreen({super.key});

  @override
  _QuestionsScreenState createState() => _QuestionsScreenState();
}

class _QuestionsScreenState extends State<QuestionsScreen> {
  // State variables
  List<Question> _unseenQuestions = [];
  Question? _currentQuestion;
  Map<String, int> _answers = {};
  int _totalQuestions = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    final String jsonString =
        await rootBundle.loadString('assets/questions.json');
    final List<dynamic> jsonData = json.decode(jsonString);

    final allQuestions = jsonData.map((q) => Question.fromJson(q)).toList();
    final answers = <String, int>{};
    for (var q in allQuestions) {
      answers[q.type] = 0;
    }

    // Start with a random question
    final random = Random();
    final firstQuestion = allQuestions[random.nextInt(allQuestions.length)];

    // Create a list of remaining questions
    final unseen = List<Question>.from(allQuestions);
    unseen.remove(firstQuestion);
    unseen.shuffle(random); // Shuffle the rest for variety

    setState(() {
      _unseenQuestions = unseen;
      _answers = answers;
      _currentQuestion = firstQuestion;
      _totalQuestions = allQuestions.length;
      _isLoading = false;
    });
  }

  void _answerQuestion(bool isYes) {
    if (_currentQuestion == null) return;

    if (isYes) {
      final String currentType = _currentQuestion!.type;
      setState(() {
        _answers[currentType] = (_answers[currentType] ?? 0) + 1;
      });
    }

    if (_unseenQuestions.isEmpty) {
      // Last question was answered, go to results
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

    // Find the first available question with a different category
    final nextQuestionIndex =
        _unseenQuestions.indexWhere((q) => q.type != lastCategory);

    Question nextQuestion;
    if (nextQuestionIndex != -1) {
      // Found a question from a different category
      nextQuestion = _unseenQuestions.removeAt(nextQuestionIndex);
    } else {
      // No questions from other categories left, just take the next available one
      nextQuestion = _unseenQuestions.removeAt(0);
    }

    setState(() {
      _currentQuestion = nextQuestion;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Загрузка...')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Анкета')),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  _currentQuestion?.question ?? 'Нет вопросов',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _answerQuestion(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[100],
                    ),
                    child: Text('Да'),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _answerQuestion(false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink[50],
                    ),
                    child: Text('Нет'),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                SizedBox(height: 8),
                LinearProgressIndicator(
                  value: _totalQuestions > 0
                      ? (_totalQuestions - _unseenQuestions.length) /
                          _totalQuestions
                      : 0,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  minHeight: 10,
                ),
                SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ResultsScreen extends StatefulWidget {
  final Map<String, int> answers;

  const ResultsScreen({super.key, required this.answers});

  @override
  _ResultsScreenState createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  Map<String, String> typeDescriptions = {};
  List<String> typeOrder = [];

  @override
  void initState() {
    super.initState();
    loadTypeDescriptions();
  }

  Future<void> loadTypeDescriptions() async {
    final String jsonString = await rootBundle.loadString('assets/types.json');
    final List<dynamic> jsonData = json.decode(jsonString);

    setState(() {
      typeDescriptions = Map.fromEntries(
          jsonData.map((item) => MapEntry(item['type'], item['description'])));
      typeOrder =
          jsonData.map<String>((item) => item['type'] as String).toList();
    });
  }

  BarChartGroupData _generateBarGroup(
    int x,
    double value,
    Color color,
  ) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: value,
          color: color,
          width: 25,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _buildBarChart() {
    final List<Color> barColors = [
      Colors.blue[200]!,
      Colors.green[200]!,
      Colors.orange[200]!,
      Colors.purple[200]!,
      Colors.red[200]!,
    ];

    final orderedEntries = typeOrder
        .map((type) => MapEntry(type, widget.answers[type] ?? 0))
        .toList();

    // Calculate the max Y value for the chart
    final maxScore = widget.answers.values.isEmpty
        ? 5 // Default value if no scores
        : widget.answers.values.reduce(max);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: (maxScore + 1).toDouble(),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < orderedEntries.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        orderedEntries[index].key,
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }
                  return const Text('');
                },
                reservedSize: 30,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 1,
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 1,
          ),
          borderData: FlBorderData(
            show: true,
            border: Border(
              bottom: BorderSide(color: Colors.black, width: 1),
              left: BorderSide(color: Colors.black, width: 1),
            ),
          ),
          barGroups: List.generate(
            orderedEntries.length,
            (index) => _generateBarGroup(
              index,
              orderedEntries[index].value.toDouble(),
              barColors[index % barColors.length],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Результаты')),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: _buildBarChart(),
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ...typeOrder.map((type) => Text(
                        '${typeDescriptions[type] ?? "Тип $type"}: ${widget.answers[type] ?? 0}',
                        style: TextStyle(fontSize: 16),
                      )),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QuestionsScreen(),
                        ),
                        (route) => false, // Удаляет все предыдущие маршруты
                      );
                    },
                    child: Text('Вернуться'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
