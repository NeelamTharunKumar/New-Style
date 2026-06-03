import 'package:flutter/material.dart';

import '../../core/design_tokens.dart';

class StatusBanner extends StatelessWidget {
  const StatusBanner({super.key, this.error, this.message, this.isBusy = false});

  final String? error;
  final String? message;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    final text = error ?? message;
    if (!isBusy && (text == null || text.isEmpty)) return const SizedBox.shrink();

    final colors = DrapeColors.of(context);
    final base = error != null ? colors.destructive : colors.primary;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: base.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: base.withOpacity(0.22)),
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
          Expanded(
            child: Text(
              isBusy ? 'Working...' : text!,
              style: TextStyle(color: base, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
