import 'package:cccapp/screens/input_screen.dart';
import 'package:cccapp/screens/output_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'cccapp',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routes: {
        InputScreen.routeName: (context) => const InputScreen(),
        OutputScreen.routeName: (context) => const OutputScreen(),
      },
      initialRoute: InputScreen.routeName,
    );
  }
}
