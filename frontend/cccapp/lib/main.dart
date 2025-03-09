import 'package:cccapp/screens/daytoday_screen.dart';
import 'package:cccapp/screens/input_screen.dart';
import 'package:cccapp/screens/login_screen.dart';
import 'package:cccapp/screens/main_screen.dart';
import 'package:cccapp/screens/output_screen.dart';
import 'package:cccapp/screens/storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'cccapp',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routes: {
        LoginScreen.routeName: (context) => const LoginScreen(),
        MainScreen.routeName: (context) => const MainScreen(),
        InputScreen.routeName: (context) => const InputScreen(),
        OutputScreen.routeName: (context) => const OutputScreen(),
        StorageScreen.routeName: (context) => const StorageScreen(),
        DaytoDayScreen.routeName: (context) => const DaytoDayScreen(),
      },
      initialRoute: LoginScreen.routeName,
    );
  }
}
