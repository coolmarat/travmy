import 'package:flutter/material.dart';

import '../../../questionnaire/presentation/screens/questions_screen.dart';
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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    loadTypeDescriptions();
  }

  Future<void> loadTypeDescriptions() async {
    final types = await _impostorTypeRepository.getImpostorTypes();
    setState(() {
      typeDescriptions = Map.fromEntries(
          types.map((item) => MapEntry(item.type, item.description)));
      typeOrder = types.map<String>((item) => item.type).toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Результаты')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Результаты')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: ResultsBarChart(
              typeOrder: typeOrder,
              answers: widget.answers,
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...typeOrder.map((type) => Text(
                        'Тип $type: ${typeDescriptions[type] ?? "Тип $type"}: ${widget.answers[type] ?? 0}',
                        style: TextStyle(fontSize: 16),
                      )),
                ],
              ),
            ),
          ),
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuestionsScreen(),
                  ),
                  (route) => false,
                );
              },
              child: Text('Вернуться'),
            ),
          ),
        ],
      ),
    );
  }
}
