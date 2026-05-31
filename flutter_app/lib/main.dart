import 'package:flutter/material.dart';
import 'presentation/screens/home_dashboard.dart';

void main() {
  runApp(const BharatFitApp());
}

class BharatFitApp extends StatelessWidget {
  const BharatFitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BharatFit AI',
      theme: ThemeData.dark(useMaterial3: true),
      home: const HomeDashboard(),
      debugShowCheckedModeBanner: false,
    );
  }
}