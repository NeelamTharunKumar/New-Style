import 'package:flutter/material.dart';

class AIStylistChat extends StatefulWidget {
  const AIStylistChat({super.key});

  @override
  State<AIStylistChat> createState() => _AIStylistChatState();
}

class _AIStylistChatState extends State<AIStylistChat> {
  final List<Map<String, String>> messages = [];
  final TextEditingController _controller = TextEditingController();

  void sendMessage(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      messages.add({'role': 'user', 'text': text});
      messages.add({
        'role': 'assistant',
        'text': _generateSmartReply(text)
      });
    });
    _controller.clear();
  }

  String _generateSmartReply(String query) {
    if (query.toLowerCase().contains('today')) {
      return "Based on your StyleDNA and local wardrobe graph, I recommend the Blue Oxford + Beige Chinos combo today.";
    }
    return "Understood. Your wardrobe has 47 compatible combinations for that request.";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Stylist')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                return Align(
                  alignment: msg['role'] == 'user' 
                      ? Alignment.centerRight 
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: msg['role'] == 'user' 
                          ? Colors.blue[700] 
                          : Colors.grey[800],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(msg['text']!),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Ask your stylist...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: sendMessage,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => sendMessage(_controller.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}