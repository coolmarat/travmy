import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  List<Map<String, String>> questions = [];
  Map<String, int> answers = {};
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    loadQuestions();
  }

  Future<void> loadQuestions() async {
    final String jsonString =
        await rootBundle.loadString('assets/questions.json');
    final List<dynamic> jsonData = json.decode(jsonString);

    setState(() {
      questions = jsonData.map((q) => Map<String, String>.from(q)).toList();
      for (var question in questions) {
        answers[question['type']!] = 0;
      }
    });
  }

  void answerQuestion(bool isYes) {
    if (isYes) {
      final String currentType = questions[currentIndex]['type']!;
      setState(() {
        answers[currentType] = answers[currentType]! + 1;
      });
    }

    if (currentIndex < questions.length - 1) {
      setState(() {
        currentIndex++;
      });
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultsScreen(answers: answers),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
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
                  questions[currentIndex]['question']!,
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
                    onPressed: () => answerQuestion(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[100],
                    ),
                    child: Text('Да'),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => answerQuestion(false),
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
                  value: (currentIndex + 1) / questions.length,
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

    return Padding(
      padding: const EdgeInsets.all(16),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 6,
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
