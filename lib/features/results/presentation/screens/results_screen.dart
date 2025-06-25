import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../intro/presentation/screens/intro_screen.dart';
import '../../data/repositories/impostor_type_repository_impl.dart';
import '../../domain/repositories/impostor_type_repository.dart';
import '../widgets/results_barchart.dart';

class ResultsScreen extends StatefulWidget {
  final Map<String, int> answers;

  const ResultsScreen({super.key, required this.answers});

  @override
  _ResultsScreenState createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  final ImpostorTypeRepository _impostorTypeRepository =
      ImpostorTypeRepositoryImpl();

  Map<String, String> typeDescriptions = {};
  List<String> typeOrder = [];
  List<Map<String, dynamic>> _resultMessages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final typesFuture = _impostorTypeRepository.getImpostorTypes();
    final messagesFuture = rootBundle.loadString('assets/result_messages.json');

    final results = await Future.wait([typesFuture, messagesFuture]);

    final types = results[0] as List<dynamic>;
    final messagesData = json.decode(results[1] as String) as List;

    setState(() {
      typeDescriptions = Map.fromEntries(
          types.map((item) => MapEntry(item.type, item.description)));
      typeOrder = types.map<String>((item) => item.type).toList();
      _resultMessages = messagesData.cast<Map<String, dynamic>>();
      _isLoading = false;
    });
  }

  String _getMessageForScore(int score) {
    for (var rule in _resultMessages) {
      if (score >= rule['min'] && score <= rule['max']) {
        return rule['message'];
      }
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Результаты')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Результаты')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 2,
            child: ResultsBarChart(
              typeOrder: typeOrder,
              answers: widget.answers,
              thresholds: _resultMessages
                  .map((e) => e['min'] as int)
                  .where((min) => min > 0)
                  .map((min) => min.toDouble())
                  .toList(),
            ),
          ),
          Expanded(
            flex: 3,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: typeOrder.map((type) {
                  final score = widget.answers[type] ?? 0;
                  final message = _getMessageForScore(score);
                  final description =
                      "$type: ${typeDescriptions[type] ?? "Тип $type"}";

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$description: $score',
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87),
                        ),
                        const SizedBox(height: 4),
                        if (message.isNotEmpty)
                          Text(
                            message,
                            style: TextStyle(
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                                color: Colors.grey[700]),
                          ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const IntroScreen(),
                  ),
                  (route) => false,
                );
              },
              child: const Text('Пройти заново'),
            ),
          ),
        ],
      ),
    );
  }
}
