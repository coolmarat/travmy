import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../../../questionnaire/presentation/screens/questions_screen.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  String _introText = '';

  @override
  void initState() {
    super.initState();
    _loadIntroText();
  }

  Future<void> _loadIntroText() async {
    final text = await rootBundle.loadString('assets/intro.txt');
    setState(() {
      _introText = text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Инструкция'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  _introText,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50), // Make button wide
              ),
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const QuestionsScreen(),
                  ),
                  (route) => false,
                );
              },
              child: const Text('НАЧАТЬ'),
            ),
          ],
        ),
      ),
    );
  }
}
