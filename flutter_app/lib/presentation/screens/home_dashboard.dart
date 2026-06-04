import 'package:flutter/material.dart';

import '../../core/design_tokens.dart';

import '../../core/branding.dart';
import '../../state/app_state.dart';
import '../widgets/app_components.dart';
import '../widgets/brand_mark.dart';
import '../widgets/status_banner.dart';
import '../widgets/weather_widget.dart';
import 'your_outfits_screen.dart';

class HomeDashboard extends StatefulWidget {
  const HomeDashboard({super.key, required this.appState});

  final AppState appState;

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  late final TextEditingController _baseUrlController;

  @override
  void initState() {
    super.initState();
    _baseUrlController = TextEditingController(text: widget.appState.apiClient.baseUrl);
    widget.appState.addListener(_refresh);
    WidgetsBinding.instance.addPostFrameCallback((_) => widget.appState.hydrate());
  }

  @override
  void dispose() {
    widget.appState.removeListener(_refresh);
    _baseUrlController.dispose();
    super.dispose();
  }

  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final state = widget.appState;
    return AppGradientScaffold(
      appBar: AppBar(
        title: const Text(AppBranding.appName),
        actions: [
          IconButton(
            tooltip: 'Check backend',
            onPressed: state.isBusy ? null : () => state.checkHealth(),
            icon: const Icon(Icons.cloud_done_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          StatusBanner(error: state.error, message: state.statusMessage, isBusy: state.isBusy),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PremiumCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const PrivacyBadge(),
                      const SizedBox(height: 16),
                      const Row(children: [BrandMark(size: 48), SizedBox(width: 12), Expanded(child: Text(AppBranding.positioning, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, height: 1.05)))],),
                      const SizedBox(height: 10),
                      Text(
                        'Create outfits from your own clothes for college, office, dates, Haldi, Sangeet and weddings.',
                        style: TextStyle(color: DrapeColors.of(context).mutedForeground, height: 1.4),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          StatPill(label: 'items', value: '${state.wardrobeItems.length}', icon: Icons.checkroom_outlined),
                          StatPill(label: 'outfits', value: '${state.outfits.length}', icon: Icons.auto_awesome_outlined),
                          StatPill(label: 'mode', value: state.profile.styleMode, icon: Icons.person_outline),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                WeatherWidget(appState: state),
                const SizedBox(height: 20),
                _PrivacyCard(state: state),
                const SizedBox(height: 20),
                TextField(
                  controller: _baseUrlController,
                  decoration: const InputDecoration(
                    labelText: 'Backend API base URL',
                    helperText: 'Android emulator usually uses http://10.0.2.2:8000. iOS simulator can use http://localhost:8000.',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: state.updateBaseUrl,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => state.updateBaseUrl(_baseUrlController.text),
                        icon: const Icon(Icons.save_outlined),
                        label: const Text('Save URL'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: state.isBusy ? null : () => state.checkHealth(),
                        icon: const Icon(Icons.health_and_safety_outlined),
                        label: const Text('Health check'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                PremiumCard(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionHeader(
                        title: 'What are you dressing for?',
                        subtitle: 'Pick an occasion and get outfits from your own wardrobe.',
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _OccasionButton(label: 'College', occasion: 'college', state: state),
                          _OccasionButton(label: 'Office', occasion: 'office', state: state),
                          _OccasionButton(label: 'Date', occasion: 'date', state: state),
                          _OccasionButton(label: 'Haldi', occasion: 'haldi', state: state),
                          _OccasionButton(label: 'Sangeet', occasion: 'sangeet', state: state),
                          _OccasionButton(label: 'Wedding', occasion: 'wedding guest', state: state),
                          _OccasionButton(label: 'Casual', occasion: 'daily casual', state: state),
                          _OccasionButton(label: 'Travel', occasion: 'travel', state: state),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PrivacyCard extends StatelessWidget {
  const _PrivacyCard({required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.lock_outline),
                SizedBox(width: 8),
                Text('Privacy contract', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 10),
            const Text('✓ Wardrobe photos stay on your phone'),
            const Text('✓ Backend receives item IDs, colors, categories and tags'),
            const Text('✓ Outfit result returns exact item IDs to show local images'),
            if (state.backendHealth != null) ...[
              const SizedBox(height: 10),
              Text('Backend: ${state.backendHealth}', style: TextStyle(color: DrapeColors.of(context).success)),
            ],
          ],
        ),
      ),
    );
  }
}

class _OccasionButton extends StatelessWidget {
  const _OccasionButton({required this.label, required this.occasion, required this.state});

  final String label;
  final String occasion;
  final AppState state;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label),
      avatar: const Icon(Icons.auto_awesome_outlined, size: 18),
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => YourOutfitsScreen(appState: state, initialOccasion: occasion)),
      ),
    );
  }
}

