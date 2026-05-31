import 'package:flutter/material.dart';

class StatusBanner extends StatelessWidget {
  const StatusBanner({super.key, this.error, this.message, this.isBusy = false});

  final String? error;
  final String? message;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    final text = error ?? message;
    if (!isBusy && (text == null || text.isEmpty)) return const SizedBox.shrink();

    final color = error != null ? Colors.red.shade900 : Colors.indigo.shade800;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.8)),
      ),
      child: Row(
        children: [
          if (isBusy) ...[
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 10),
          ],
          Expanded(child: Text(isBusy ? 'Working...' : text!)),
        ],
      ),
    );
  }
}
