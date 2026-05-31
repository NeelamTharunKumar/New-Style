import 'package:flutter/material.dart';

import '../../core/design_tokens.dart';

import '../../data/app_models.dart';
import '../../state/app_state.dart';
import '../widgets/app_components.dart';
import '../widgets/local_wardrobe_image.dart';
import '../widgets/status_banner.dart';
import 'outfit_detail_screen.dart';
import 'outfit_preview_screen.dart';
import 'wardrobe_screen.dart';

class YourOutfitsScreen extends StatefulWidget {
  const YourOutfitsScreen({super.key, required this.appState, this.initialOccasion});

  final AppState appState;
  final String? initialOccasion;

  @override
  State<YourOutfitsScreen> createState() => _YourOutfitsScreenState();
}

class _YourOutfitsScreenState extends State<YourOutfitsScreen> {
  final _temperatureController = TextEditingController(text: '34');
  String _occasion = 'office';
  String _weatherCondition = 'hot_humid';

  static const _occasions = [
    'college',
    'office',
    'date',
    'interview',
    'haldi',
    'sangeet',
    'mehendi',
    'wedding guest',
    'reception',
    'pooja',
    'festival',
    'travel',
    'monsoon day',
    'summer day',
  ];

  @override
  void initState() {
    super.initState();
    _occasion = widget.initialOccasion ?? 'office';
    widget.appState.addListener(_refresh);
  }

  @override
  void dispose() {
    widget.appState.removeListener(_refresh);
    _temperatureController.dispose();
    super.dispose();
  }

  void _refresh() => setState(() {});

  Future<void> _generate() async {
    await widget.appState.generateOutfits(
      occasion: _occasion,
      temperatureC: double.tryParse(_temperatureController.text.trim()),
      weatherCondition: _weatherCondition,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.appState;
    return AppGradientScaffold(
      appBar: AppBar(title: const Text('Your Outfits')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          StatusBanner(error: state.error, message: state.statusMessage, isBusy: state.isBusy),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(title: 'What are you dressing for?', subtitle: 'Pick an occasion and BharatFit will build visual outfits from your own clothes.'),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: const ['college', 'office', 'date', 'haldi', 'sangeet', 'wedding guest', 'daily casual', 'travel']
                      .map((occasion) => ChoiceChip(
                            label: Text(_labelForOccasion(occasion)),
                            selected: _occasion == occasion,
                            onSelected: (_) => setState(() => _occasion = occasion),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _occasion,
                  decoration: const InputDecoration(labelText: 'More occasions', border: OutlineInputBorder()),
                  items: _occasions.map((occasion) => DropdownMenuItem(value: occasion, child: Text(_labelForOccasion(occasion)))).toList(),
                  onChanged: (value) => setState(() => _occasion = value ?? 'office'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _temperatureController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Temperature °C', border: OutlineInputBorder()),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _weatherCondition,
                        decoration: const InputDecoration(labelText: 'Weather', border: OutlineInputBorder()),
                        items: const [
                          DropdownMenuItem(value: 'hot_humid', child: Text('Hot humid')),
                          DropdownMenuItem(value: 'hot_dry', child: Text('Hot dry')),
                          DropdownMenuItem(value: 'monsoon', child: Text('Monsoon')),
                          DropdownMenuItem(value: 'winter', child: Text('Winter')),
                          DropdownMenuItem(value: 'indoor_ac', child: Text('Indoor AC')),
                        ],
                        onChanged: (value) => setState(() => _weatherCondition = value ?? 'hot_humid'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (state.wardrobeItems.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('No wardrobe items found.'),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => WardrobeScreen(appState: state)),
                            ),
                            icon: const Icon(Icons.checkroom_outlined),
                            label: const Text('Add wardrobe items'),
                          ),
                        ],
                      ),
                    ),
                  ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: state.isBusy || state.wardrobeItems.isEmpty ? null : _generate,
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text('Generate outfits'),
                  ),
                ),
                const SizedBox(height: 20),
                if (state.outfits.isEmpty)
                  const EmptyState(
                    icon: Icons.auto_awesome_outlined,
                    title: 'No generated outfits yet',
                    subtitle: 'Add wardrobe items, choose an occasion, and BharatFit will compose looks from your own clothes.',
                  )
                else
                  ...state.outfits.map((outfit) => _OutfitCard(outfit: outfit, state: state)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _labelForOccasion(String occasion) {
  return switch (occasion) {
    'college' => 'College',
    'office' => 'Office',
    'date' => 'Date',
    'haldi' => 'Haldi',
    'sangeet' => 'Sangeet',
    'wedding guest' => 'Wedding',
    'daily casual' => 'Casual',
    'travel' => 'Travel',
    _ => occasion.split(' ').map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}').join(' '),
  };
}

class _OutfitCard extends StatelessWidget {
  const _OutfitCard({required this.outfit, required this.state});

  final OutfitRecommendation outfit;
  final AppState state;

  @override
  Widget build(BuildContext context) {
    final items = outfit.itemIds.map(state.itemById).whereType<WardrobeItem>().toList();
    return InkWell(
      borderRadius: BorderRadius.circular(28),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => OutfitDetailScreen(appState: state, outfit: outfit)),
      ),
      child: PremiumCard(
        margin: const EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text(outfit.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800))),
                  _ScorePill(score: outfit.score),
                ],
              ),
              const SizedBox(height: 14),
              if (items.isNotEmpty)
                SizedBox(
                  height: 116,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) => _OutfitItemTile(item: items[index]),
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemCount: items.length,
                  ),
                )
              else
                Text('Item IDs: ${outfit.itemIds.join(', ')}'),
              const SizedBox(height: 14),
              Text(outfit.why),
              if (outfit.stylingTips.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text('Styling tips', style: TextStyle(fontWeight: FontWeight.w700)),
                ...outfit.stylingTips.map((tip) => Text('• $tip')),
              ],
              if (outfit.avoid.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text('Avoid', style: TextStyle(fontWeight: FontWeight.w700)),
                ...outfit.avoid.map((tip) => Text('• $tip')),
              ],
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: outfit.scoreBreakdown.values.entries
                    .map((entry) => Chip(label: Text('${entry.key}: ${entry.value.toStringAsFixed(0)}')))
                    .toList(),
              ),
              const SizedBox(height: 14),
              const Text('Actions', style: TextStyle(fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => OutfitPreviewScreen(appState: state, outfit: outfit, occasion: _inferOccasion(outfit))),
                    ),
                    icon: const Icon(Icons.checkroom_outlined),
                    label: const Text('Preview Look'),
                  ),
                  FilledButton.icon(
                    onPressed: state.isBusy ? null : () => state.recordOutfitFeedback(outfit: outfit, occasion: _inferOccasion(outfit), worn: true, rating: 5),
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Wear today'),
                  ),
                  OutlinedButton.icon(
                    onPressed: state.isBusy ? null : () => state.recordOutfitFeedback(outfit: outfit, occasion: _inferOccasion(outfit), favorite: true, rating: 5),
                    icon: const Icon(Icons.bookmark_border),
                    label: const Text('Save'),
                  ),
                  OutlinedButton.icon(
                    onPressed: state.isBusy ? null : () => state.generateOutfits(occasion: _inferOccasion(outfit)),
                    icon: const Icon(Icons.swap_horiz),
                    label: const Text('Swap item'),
                  ),
                  OutlinedButton.icon(
                    onPressed: state.isBusy ? null : () => state.recordOutfitFeedback(outfit: outfit, occasion: _inferOccasion(outfit), rejected: true, rating: 1),
                    icon: const Icon(Icons.thumb_down_alt_outlined),
                    label: const Text('Not my style'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
String _inferOccasion(OutfitRecommendation outfit) {
  final title = outfit.title.toLowerCase();
  for (final occasion in _YourOutfitsScreenState._occasions) {
    if (title.contains(occasion)) return occasion;
  }
  return 'daily casual';
}

class _OutfitItemTile extends StatelessWidget {
  const _OutfitItemTile({required this.item});

  final WardrobeItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 132,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LocalWardrobeImage(
            localImageRef: item.localImageRef,
            hexColor: item.hexColor,
            width: double.infinity,
            height: 42,
          ),
          const SizedBox(height: 8),
          Text(item.displayName, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700)),
          const Spacer(),
          Text(item.localImageRef ?? item.itemId ?? item.category, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
        ],
      ),
    );
  }
}

class _ScorePill extends StatelessWidget {
  const _ScorePill({required this.score});

  final double score;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: Colors.green.shade800, borderRadius: BorderRadius.circular(99)),
      child: Text(score.toStringAsFixed(0), style: const TextStyle(fontWeight: FontWeight.w800)),
    );
  }
}
