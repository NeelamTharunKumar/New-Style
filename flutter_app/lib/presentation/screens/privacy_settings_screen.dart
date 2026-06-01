import 'package:flutter/material.dart';

import '../../core/design_tokens.dart';
import 'package:flutter/services.dart';

import '../../state/app_state.dart';
import '../widgets/status_banner.dart';

class PrivacySettingsScreen extends StatefulWidget {
  const PrivacySettingsScreen({super.key, required this.appState});

  final AppState appState;

  @override
  State<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
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

  Future<void> _exportData() async {
    final export = await widget.appState.exportLocalData();
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Local structured data export'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: SelectableText(export, style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: export));
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Copy'),
          ),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  Future<void> _confirmClearAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear local data?'),
        content: const Text('This clears local profile, wardrobe items and saved outfit results from this device. Backend prototype data is not guaranteed to be deleted.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Clear local data')),
        ],
      ),
    );
    if (confirmed == true) await widget.appState.clearLocalData();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.appState;
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy & Local Data')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          StatusBanner(error: state.error, message: state.statusMessage, isBusy: state.isBusy),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Privacy-first storage', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Text(
                  'Phase 3 makes the Flutter app local-first. Profile, wardrobe features and generated outfit results are persisted on this device. Backend calls use structured data only.',
                  style: TextStyle(color: AppColors.mutedForeground, height: 1.4),
                ),
                const SizedBox(height: 16),
                const _PrivacyRuleCard(),
                const SizedBox(height: 16),
                _DataSummaryCard(state: state),
                const SizedBox(height: 16),
                _ActionCard(
                  icon: Icons.sync_outlined,
                  title: 'Sync structured data to backend',
                  subtitle: 'Sends profile and wardrobe features only. No photos.',
                  label: 'Sync now',
                  onPressed: state.isBusy ? null : state.syncStructuredDataToBackend,
                ),
                _ActionCard(
                  icon: Icons.ios_share_outlined,
                  title: 'Export local structured data',
                  subtitle: 'Shows JSON containing profile, wardrobe features, outfit history and local image refs.',
                  label: 'Export JSON',
                  onPressed: _exportData,
                ),
                _ActionCard(
                  icon: Icons.delete_sweep_outlined,
                  title: 'Clear saved outfit results',
                  subtitle: 'Keeps profile and wardrobe but removes generated outfit history.',
                  label: 'Clear outfits',
                  onPressed: state.isBusy ? null : state.clearSavedOutfits,
                ),
                _ActionCard(
                  icon: Icons.warning_amber_outlined,
                  title: 'Clear all local data',
                  subtitle: 'Removes local profile, wardrobe and outfits from this device.',
                  label: 'Clear local data',
                  destructive: true,
                  onPressed: state.isBusy ? null : _confirmClearAll,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PrivacyRuleCard extends StatelessWidget {
  const _PrivacyRuleCard();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [Icon(Icons.lock_outline), SizedBox(width: 8), Text('What leaves the app?', style: TextStyle(fontWeight: FontWeight.w800))]),
            SizedBox(height: 10),
            Text('Allowed: item IDs, categories, colors, fabrics, tags, profile context, weather/occasion.'),
            SizedBox(height: 6),
            Text('Not allowed: raw selfies, wardrobe photos, face images, camera frames.'),
            SizedBox(height: 6),
            Text('Visual cards use local image references such as local://wardrobe/shirt_001.jpg.'),
          ],
        ),
      ),
    );
  }
}

class _DataSummaryCard extends StatelessWidget {
  const _DataSummaryCard({required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Local data summary', style: TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            Text('Profile: ${state.profile.userId} · ${state.profile.styleMode}'),
            Text('Wardrobe items: ${state.wardrobeItems.length}'),
            Text('Saved outfits: ${state.outfits.length}'),
            Text('Backend URL: ${state.apiClient.baseUrl}'),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.label,
    required this.onPressed,
    this.destructive = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String label;
  final VoidCallback? onPressed;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [Icon(icon), const SizedBox(width: 8), Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)))]),
            const SizedBox(height: 8),
            Text(subtitle, style: TextStyle(color: AppColors.mutedForeground)),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: destructive
                  ? FilledButton.tonal(onPressed: onPressed, child: Text(label))
                  : ElevatedButton(onPressed: onPressed, child: Text(label)),
            ),
          ],
        ),
      ),
    );
  }
}
