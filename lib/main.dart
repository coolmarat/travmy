import 'package:flutter/material.dart';

import 'features/intro/presentation/screens/intro_screen.dart';

void main() {
  runApp(const ImpostorSyndromeApp());
}

class ImpostorSyndromeApp extends StatelessWidget {
  const ImpostorSyndromeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: IntroScreen(),
    );
  }
}
