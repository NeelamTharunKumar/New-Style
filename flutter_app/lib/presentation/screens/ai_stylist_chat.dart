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
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    widget.appState.addListener(_refresh);
  }

  @override
  void dispose() {
    widget.appState.removeListener(_refresh);
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _refresh() {
    setState(() {});
    if (widget.appState.isBusy) {
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatTime(DateTime time) {
    final hr = time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
    final min = time.minute.toString().padLeft(2, '0');
    final ampm = time.hour >= 12 ? 'PM' : 'AM';
    return '$hr:$min $ampm';
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    setState(() {
      messages.add({
        'role': 'user',
        'text': text.trim(),
        'time': _formatTime(DateTime.now()),
      });
    });
    _controller.clear();
    _scrollToBottom();
    
    final reply = await widget.appState.askStylist(text.trim());
    if (!mounted) return;
    
    setState(() {
      messages.add({
        'role': 'assistant',
        'text': reply.isEmpty ? 'I could not get a reply. Check backend connection.' : reply,
        'time': _formatTime(DateTime.now()),
      });
    });
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.appState;
    final colors = DrapeColors.of(context);
    
    return Scaffold(
      appBar: AppBar(title: const Text('AI Stylist')),
      body: Column(
        children: [
          StatusBanner(error: state.error, message: state.statusMessage, isBusy: false),
          Expanded(
            child: messages.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Ask about an occasion. Phase 2 uses the backend chat stub; Phase 4 will add a strict JSON LLM adapter with no-photo input.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: colors.mutedForeground),
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length + (state.isBusy ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == messages.length) {
                        return _buildTypingIndicator(colors);
                      }
                      final msg = messages[index];
                      final isUser = msg['role'] == 'user';
                      return _buildChatBubble(msg, isUser, colors);
                    },
                  ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Ask your stylist...',
                        hintStyle: TextStyle(color: colors.mutedForeground),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: colors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: colors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: colors.primary, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      ),
                      onSubmitted: state.isBusy ? null : sendMessage,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: state.isBusy ? colors.muted : colors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: state.isBusy ? null : () => sendMessage(_controller.text),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatBubble(Map<String, String> msg, bool isUser, DrapeColors colors) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: colors.primarySoft,
              child: Icon(Icons.auto_awesome, size: 16, color: colors.primary),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isUser ? colors.primary : colors.surface,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isUser ? 16 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 16),
                    ),
                    border: isUser ? null : Border.all(color: colors.border),
                    boxShadow: AppShadows.cardFor(context),
                  ),
                  child: Text(
                    msg['text']!,
                    style: TextStyle(
                      color: isUser ? Colors.white : colors.foreground,
                      fontSize: 15,
                    ),
                  ),
                ),
                if (msg['time'] != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    msg['time']!,
                    style: TextStyle(fontSize: 11, color: colors.mutedForeground),
                  ),
                ],
              ],
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: colors.muted,
              child: Icon(Icons.person, size: 16, color: colors.foreground),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator(DrapeColors colors) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: colors.primarySoft,
            child: Icon(Icons.auto_awesome, size: 16, color: colors.primary),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(16),
              ),
              border: Border.all(color: colors.border),
              boxShadow: AppShadows.cardFor(context),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _DotIndicator(delay: 0, color: colors.primary),
                const SizedBox(width: 4),
                _DotIndicator(delay: 200, color: colors.primary),
                const SizedBox(width: 4),
                _DotIndicator(delay: 400, color: colors.primary),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DotIndicator extends StatefulWidget {
  const _DotIndicator({required this.delay, required this.color});
  final int delay;
  final Color color;

  @override
  State<_DotIndicator> createState() => _DotIndicatorState();
}

class _DotIndicatorState extends State<_DotIndicator> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
      ),
    );
  }
}
