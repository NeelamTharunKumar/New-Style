import 'package:flutter/material.dart';
import '../../core/di.dart';

class WardrobeScreen extends StatefulWidget {
  const WardrobeScreen({super.key});

  @override
  State<WardrobeScreen> createState() => _WardrobeScreenState();
}

class _WardrobeScreenState extends State<WardrobeScreen> {
  final LocalMLService _ml = MediaPipeLocalMLService();
  List<Map<String, dynamic>> wardrobeItems = [];

  Future<void> addItem() async {
    final features = await _ml.extractGarmentFeatures('dummy_path.jpg');
    
    setState(() {
      wardrobeItems.add({
        'name': '${features['color']} ${features['category']}',
        'features': features,
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Wardrobe')),
      floatingActionButton: FloatingActionButton(
        onPressed: addItem,
        child: const Icon(Icons.add_a_photo),
      ),
      body: wardrobeItems.isEmpty
          ? const Center(child: Text('No items yet. Tap + to add clothing'))
          : ListView.builder(
              itemCount: wardrobeItems.length,
              itemBuilder: (context, index) {
                final item = wardrobeItems[index];
                return ListTile(
                  leading: const Icon(Icons.checkroom),
                  title: Text(item['name']),
                  subtitle: Text(item['features']['style']),
                );
              },
            ),
    );
  }
}