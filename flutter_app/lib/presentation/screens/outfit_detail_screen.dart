import 'package:flutter/material.dart';

import '../../core/design_tokens.dart';
import '../../data/app_models.dart';
import '../../state/app_state.dart';
import '../widgets/app_components.dart';
import '../widgets/local_wardrobe_image.dart';
import '../widgets/status_banner.dart';

class OutfitDetailScreen extends StatefulWidget {
  const OutfitDetailScreen({super.key, required this.appState, required this.outfit, this.occasion});

  final AppState appState;
  final OutfitRecommendation outfit;
  final String? occasion;

  @override
  State<OutfitDetailScreen> createState() => _OutfitDetailScreenState();
}

class _OutfitDetailScreenState extends State<OutfitDetailScreen> {
  int _rating = 5;

  @override
  void initState() {
    super.initState();
    widget.appState.addListener(_refresh);
  }

  @override
  void dispose() {
    widget.appState.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() => setState(() {});

  Future<void> _feedback({bool worn = false, bool favorite = false, bool rejected = false}) async {
    await widget.appState.recordOutfitFeedback(
      outfit: widget.outfit,
      occasion: widget.occasion,
      rating: _rating,
      worn: worn,
      favorite: favorite,
      rejected: rejected,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.appState;
    final items = widget.outfit.itemIds.map(state.itemById).whereType<WardrobeItem>().toList();
    return AppGradientScaffold(
      appBar: AppBar(title: const Text('Outfit details')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          StatusBanner(error: state.error, message: state.statusMessage, isBusy: state.isBusy),
          PremiumCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(widget.outfit.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, height: 1.05))),
                    _Score(score: widget.outfit.score),
                  ],
                ),
                const SizedBox(height: 16),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 0.86),
                  itemBuilder: (context, index) => _ItemCard(item: items[index]),
                ),
                const SizedBox(height: 16),
                const Text('Why this works', style: TextStyle(fontWeight: FontWeight.w900)),
                const SizedBox(height: 6),
                Text(widget.outfit.why, style: const TextStyle(height: 1.4)),
                if (widget.outfit.stylingTips.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  const Text('Styling tips', style: TextStyle(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 6),
                  ...widget.outfit.stylingTips.map((tip) => Text('• $tip')),
                ],
                if (widget.outfit.avoid.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  const Text('Avoid', style: TextStyle(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 6),
                  ...widget.outfit.avoid.map((tip) => Text('• $tip')),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          PremiumCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(title: 'Personalize future outfits', subtitle: 'Your feedback adjusts future ranking without sending photos.'),
                const SizedBox(height: 12),
                Text('Rating: $_rating/5'),
                Slider(value: _rating.toDouble(), min: 1, max: 5, divisions: 4, label: '$_rating', onChanged: (v) => setState(() => _rating = v.round())),
                Row(
                  children: [
                    Expanded(child: ElevatedButton.icon(onPressed: state.isBusy ? null : () => _feedback(favorite: true), icon: const Icon(Icons.favorite_outline), label: const Text('Favorite'))),
                    const SizedBox(width: 8),
                    Expanded(child: OutlinedButton.icon(onPressed: state.isBusy ? null : () => _feedback(worn: true), icon: const Icon(Icons.check_circle_outline), label: const Text('Worn'))),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(onPressed: state.isBusy ? null : () => _feedback(rejected: true), icon: const Icon(Icons.thumb_down_alt_outlined), label: const Text('Not my style')),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  const _ItemCard({required this.item});
  final WardrobeItem item;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: LocalWardrobeImage(localImageRef: item.localImageRef, hexColor: item.hexColor, borderRadius: 14)),
          const SizedBox(height: 8),
          Text(item.displayName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800)),
          Text(item.category, style: const TextStyle(color: AppColors.mutedForeground, fontSize: 12)),
        ],
      ),
    );
  }
}

class _Score extends StatelessWidget {
  const _Score({required this.score});
  final double score;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.14), borderRadius: BorderRadius.circular(99)),
      child: Text(score.toStringAsFixed(0), style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.w900)),
    );
  }
}
