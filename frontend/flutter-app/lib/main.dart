import 'package:flutter/material.dart';
import 'screens/prediction_form.dart';

void main() {
  runApp(const HousingApp());
}

class HousingApp extends StatelessWidget {
  const HousingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lagos Housing Predictor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1F6FEB)),
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      home: const PredictionFormScreen(),
    );
  }
}
