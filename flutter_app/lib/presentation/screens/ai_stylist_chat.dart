import 'package:flutter/material.dart';

import '../../core/design_tokens.dart';
import '../../state/app_state.dart';
import '../widgets/status_banner.dart';

class AIStylistChat extends StatefulWidget {
  const AIStylistChat({super.key, required this.appState});

  final AppState appState;

  @override
  State<AIStylistChat> createState() => _AIStylistChatState();
}

class _AIStylistChatState extends State<AIStylistChat> {
  final List<Map<String, String>> messages = [];
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.appState.addListener(_refresh);
  }

  @override
  void dispose() {
    widget.appState.removeListener(_refresh);
    _controller.dispose();
    super.dispose();
  }

  void _refresh() => setState(() {});

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    setState(() {
      messages.add({'role': 'user', 'text': text.trim()});
    });
    _controller.clear();
    final reply = await widget.appState.askStylist(text.trim());
    if (!mounted) return;
    setState(() {
      messages.add({
        'role': 'assistant',
        'text': reply.isEmpty ? 'I could not get a reply. Check backend connection.' : reply,
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.appState;
    return Scaffold(
      appBar: AppBar(title: const Text('AI Stylist')),
      body: Column(
        children: [
          StatusBanner(error: state.error, message: state.statusMessage, isBusy: state.isBusy),
          Expanded(
            child: messages.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'Ask about an occasion. Phase 2 uses the backend chat stub; Phase 4 will add a strict JSON LLM adapter with no-photo input.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      final isUser = msg['role'] == 'user';
                      return Align(
                        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.all(8),
                          padding: const EdgeInsets.all(12),
                          constraints: const BoxConstraints(maxWidth: 320),
                          decoration: BoxDecoration(
                            color: isUser ? DrapeColors.of(context).primary : DrapeColors.of(context).surface,
                            borderRadius: BorderRadius.circular(16),
                            border: isUser ? null : Border.all(color: DrapeColors.of(context).border),
                          ),
                          child: Text(msg['text']!, style: TextStyle(color: isUser ? Colors.white : DrapeColors.of(context).foreground)),
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
                    onSubmitted: state.isBusy ? null : sendMessage,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: state.isBusy ? null : () => sendMessage(_controller.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
