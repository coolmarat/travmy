import 'package:flutter/material.dart';
import 'features/questionnaire/presentation/screens/questions_screen.dart';

void main() {
  runApp(const ImpostorSyndromeApp());
}

class ImpostorSyndromeApp extends StatelessWidget {
  const ImpostorSyndromeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: QuestionsScreen(),
    );
  }
}
