import 'package:flutter/material.dart';

import '../../core/design_tokens.dart';
import '../../data/app_models.dart';
import '../../state/app_state.dart';
import '../widgets/app_components.dart';
import '../widgets/local_wardrobe_image.dart';

class WardrobeItemDetailScreen extends StatelessWidget {
  const WardrobeItemDetailScreen({super.key, required this.appState, required this.item});

  final AppState appState;
  final WardrobeItem item;

  @override
  Widget build(BuildContext context) {
    return AppGradientScaffold(
      appBar: AppBar(title: const Text('Wardrobe item')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          PremiumCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 320, child: LocalWardrobeImage(localImageRef: item.localImageRef, hexColor: item.hexColor, borderRadius: 24)),
                const SizedBox(height: 18),
                Text(item.displayName, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
                const SizedBox(height: 6),
                const PrivacyBadge(label: 'Stored locally; backend gets structured fields only'),
                const SizedBox(height: 18),
                _Info(label: 'Category', value: item.category),
                _Info(label: 'Color', value: item.color),
                _Info(label: 'Fabric', value: item.fabric ?? 'Not set'),
                _Info(label: 'Fit', value: item.fit ?? 'Not set'),
                _Info(label: 'Formality', value: '${item.formality}/10'),
                _Info(label: 'Occasions', value: item.occasionTags.join(', ')),
                _Info(label: 'Local image ref', value: item.localImageRef ?? 'None'),
                if (item.featureVectorSummary.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  const Text('Local feature summary', style: TextStyle(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 6),
                  Text(item.featureVectorSummary.toString(), style: TextStyle(color: DrapeColors.of(context).mutedForeground)),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Item?'),
                  content: const Text('This will remove the item from your wardrobe and delete its local image. This cannot be undone.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: FilledButton.styleFrom(backgroundColor: DrapeColors.of(context).destructive),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                appState.deleteWardrobeItem(item).then((_) {
                  if (context.mounted) Navigator.pop(context);
                });
              }
            },
            icon: const Icon(Icons.delete_outline),
            label: const Text('Delete item and local image'),
          ),
        ],
      ),
    );
  }
}

class _Info extends StatelessWidget {
  const _Info({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 96, child: Text(label, style: TextStyle(color: DrapeColors.of(context).mutedForeground))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w700))),
        ],
      ),
    );
  }
}
