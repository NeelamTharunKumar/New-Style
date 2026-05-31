import 'package:flutter/material.dart';
import '../../core/di.dart';

class StyleProfileScreen extends StatefulWidget {
  const StyleProfileScreen({super.key});

  @override
  State<StyleProfileScreen> createState() => _StyleProfileScreenState();
}

class _StyleProfileScreenState extends State<StyleProfileScreen> {
  final LocalMLService _ml = MediaPipeLocalMLService();
  Map<String, dynamic>? report;

  Future<void> analyzeSelfie() async {
    final features = await _ml.extractStyleProfileFeatures([]);
    setState(() {
      report = features;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Style Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: analyzeSelfie,
              child: const Text('Analyze Style Profile (On-Device)'),
            ),
            const SizedBox(height: 30),
            if (report != null) ...[
              const Text('Your Style Profile', style: TextStyle(fontSize: 20)),
              const SizedBox(height: 20),
              ...report!.entries.map((e) => 
                ListTile(
                  title: Text(e.key.replaceAll('_', ' ').toUpperCase()),
                  trailing: Text(e.value.toString()),
                )
              ),
            ]
          ],
        ),
      ),
    );
  }
}