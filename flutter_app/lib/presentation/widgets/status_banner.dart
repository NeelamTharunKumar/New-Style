import 'package:flutter/material.dart';

import '../../core/design_tokens.dart';
import 'shimmer_loading.dart';

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
        color: base.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: base.withValues(alpha: 0.22)),
      ),
      child: Row(
        children: [
          if (isBusy) ...[
            ShimmerPulseIndicator(size: 18, color: base),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Text(
              isBusy ? 'Working on it…' : text!,
              style: TextStyle(color: base, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

