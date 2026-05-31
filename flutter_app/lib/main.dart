import 'package:flutter/material.dart';
import 'presentation/screens/home_dashboard.dart';

void main() {
  runApp(const StyleDNAApp());
}

class StyleDNAApp extends StatelessWidget {
  const StyleDNAApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StyleDNA AI',
      theme: ThemeData.dark(useMaterial3: true),
      home: const HomeDashboard(),
      debugShowCheckedModeBanner: false,
    );
  }
}