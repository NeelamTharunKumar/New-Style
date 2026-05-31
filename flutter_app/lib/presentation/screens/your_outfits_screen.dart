import 'package:flutter/material.dart';
import '../../core/di.dart';

class YourOutfitsScreen extends StatefulWidget {
  const YourOutfitsScreen({super.key});

  @override
  State<YourOutfitsScreen> createState() => _YourOutfitsScreenState();
}

class _YourOutfitsScreenState extends State<YourOutfitsScreen> {
  final LocalMLService _ml = MediaPipeLocalMLService();
  List<Map<String, dynamic>> outfits = [];
  bool isGenerating = false;

  Future<void> generateOutfits(String occasion) async {
    setState(() => isGenerating = true);
    
    final response = await _simulateLocalGraphCall(occasion);
    
    setState(() {
      outfits = response;
      isGenerating = false;
    });
  }

  Future<List<Map<String, dynamic>>> _simulateLocalGraphCall(String occasion) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return [
      {
        'items': ['White T-Shirt', 'Black Jeans', 'White Sneakers'],
        'score': 92,
        'why': 'High contrast minimalist look perfect for college. Neutral palette matches your BharatFit.'
      },
      {
        'items': ['Blue Oxford Shirt', 'Beige Chinos', 'Brown Loafers'],
        'score': 88,
        'why': 'Smart casual harmony. Earth tones complement your skin undertone.'
      }
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Outfits')),
      body: Column(
        children: [
          Wrap(
            spacing: 8,
            children: ['College', 'Office', 'Party', 'Wedding'].map((o) => 
              ElevatedButton(
                onPressed: () => generateOutfits(o),
                child: Text(o)
              )
            ).toList(),
          ),
          const SizedBox(height: 20),
          if (isGenerating) const CircularProgressIndicator(),
          Expanded(
            child: ListView.builder(
              itemCount: outfits.length,
              itemBuilder: (context, index) {
                final outfit = outfits[index];
                return Card(
                  child: ListTile(
                    title: Text(outfit['items'].join(' + ')),
                    subtitle: Text(outfit['why']),
                    trailing: Text('${outfit['score']}'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}