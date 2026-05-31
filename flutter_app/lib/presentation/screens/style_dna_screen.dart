import 'package:flutter/material.dart';
import '../../core/di.dart';

class StyleDNAScreen extends StatefulWidget {
  const StyleDNAScreen({super.key});

  @override
  State<StyleDNAScreen> createState() => _StyleDNAScreenState();
}

class _StyleDNAScreenState extends State<StyleDNAScreen> {
  final LocalMLService _ml = MediaPipeLocalMLService();
  Map<String, dynamic>? report;

  Future<void> analyzeSelfie() async {
    final features = await _ml.extractStyleDNAFeatures([]);
    setState(() {
      report = features;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Style DNA Analysis')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: analyzeSelfie,
              child: const Text('Analyze Selfie (On-Device)'),
            ),
            const SizedBox(height: 30),
            if (report != null) ...[
              const Text('Your StyleDNA Report', style: TextStyle(fontSize: 20)),
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