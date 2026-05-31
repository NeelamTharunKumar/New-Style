import 'package:flutter/material.dart';
import 'style_dna_screen.dart';
import 'wardrobe_screen.dart';
import 'your_outfits_screen.dart';
import 'ai_stylist_chat.dart';

class HomeDashboard extends StatelessWidget {
  const HomeDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('StyleDNA AI')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome to your StyleDNA', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StyleDNAScreen())),
              child: const Text('Style DNA Analysis'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WardrobeScreen())),
              child: const Text('Your Wardrobe'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const YourOutfitsScreen())),
              child: const Text('Your Outfits (USP)'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AIStylistChat())),
              child: const Text('AI Stylist Chat'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.checkroom), label: 'Wardrobe'),
          BottomNavigationBarItem(icon: Icon(Icons.auto_awesome), label: 'Outfits'),
        ],
      ),
    );
  }
}