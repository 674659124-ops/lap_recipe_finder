import 'package:flutter/material.dart';
import 'package:lap_recipe_finder/screens/login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recipe Finder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF378F45),
          primary: const Color(0xFF378F45),
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF9F9F9),
      ),
      home: const LoginScreen(),
    );
  }
}
