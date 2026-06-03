import 'package:flutter/material.dart';

import '../../core/design_tokens.dart';

import '../../data/app_models.dart';
import '../../state/app_state.dart';
import '../widgets/app_components.dart';
import '../widgets/status_banner.dart';

class StyleProfileScreen extends StatefulWidget {
  const StyleProfileScreen({super.key, required this.appState});

  final AppState appState;

  @override
  State<StyleProfileScreen> createState() => _StyleProfileScreenState();
}

class _StyleProfileScreenState extends State<StyleProfileScreen> {
  late final TextEditingController _userIdController;
  late final TextEditingController _skinToneController;
  late final TextEditingController _bodyShapeController;
  late final TextEditingController _preferencesController;
  late final TextEditingController _regionController;
  String _styleMode = 'mixed';
  String _climate = 'hot_humid';
  bool _budgetConscious = true;

  @override
  void initState() {
    super.initState();
    final profile = widget.appState.profile;
    _userIdController = TextEditingController(text: profile.userId);
    _skinToneController = TextEditingController(text: profile.skinTone ?? 'medium warm');
    _bodyShapeController = TextEditingController(text: profile.bodyShape ?? '');
    _preferencesController = TextEditingController(text: profile.preferences.join(', '));
    _regionController = TextEditingController(text: profile.region);
    _styleMode = profile.styleMode;
    _climate = profile.climatePreference ?? 'hot_humid';
    _budgetConscious = profile.budgetConscious;
    widget.appState.addListener(_refresh);
  }

  @override
  void dispose() {
    widget.appState.removeListener(_refresh);
    _userIdController.dispose();
    _skinToneController.dispose();
    _bodyShapeController.dispose();
    _preferencesController.dispose();
    _regionController.dispose();
    super.dispose();
  }

  void _refresh() => setState(() {});

  Future<void> _save() async {
    final profile = UserProfile(
      userId: _userIdController.text.trim().isEmpty ? 'demo_user' : _userIdController.text.trim(),
      styleMode: _styleMode,
      region: _regionController.text.trim().isEmpty ? 'India' : _regionController.text.trim(),
      climatePreference: _climate,
      skinTone: _skinToneController.text.trim().isEmpty ? null : _skinToneController.text.trim(),
      bodyShape: _bodyShapeController.text.trim().isEmpty ? null : _bodyShapeController.text.trim(),
      preferences: splitTags(_preferencesController.text),
      budgetConscious: _budgetConscious,
    );
    await widget.appState.saveProfile(profile);
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.appState;
    return AppGradientScaffold(
      appBar: AppBar(title: const Text('Style Profile')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          StatusBanner(error: state.error, message: state.statusMessage, isBusy: state.isBusy),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Set your styling context', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text(
                  'Phase 2 uses manual structured fields. Later phases will extract many of these locally from photos.',
                  style: TextStyle(color: DrapeColors.of(context).mutedForeground),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _userIdController,
                  decoration: const InputDecoration(labelText: 'User ID', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  // ignore: deprecated_member_use
                  value: _styleMode,
                  decoration: const InputDecoration(labelText: 'Style mode', border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(value: 'menswear', child: Text('Menswear')),
                    DropdownMenuItem(value: 'womenswear', child: Text('Womenswear')),
                    DropdownMenuItem(value: 'mixed', child: Text('Mixed / Unisex')),
                  ],
                  onChanged: (value) => setState(() => _styleMode = value ?? 'mixed'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _skinToneController,
                  decoration: const InputDecoration(
                    labelText: 'Skin tone / undertone',
                    hintText: 'medium warm, dusky warm, fair cool, neutral...',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _bodyShapeController,
                  decoration: const InputDecoration(labelText: 'Body shape / proportions (optional)', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  // ignore: deprecated_member_use
                  value: _climate,
                  decoration: const InputDecoration(labelText: 'Primary climate', border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(value: 'hot_humid', child: Text('Hot + humid')),
                    DropdownMenuItem(value: 'hot_dry', child: Text('Hot + dry')),
                    DropdownMenuItem(value: 'monsoon', child: Text('Monsoon')),
                    DropdownMenuItem(value: 'winter', child: Text('Winter')),
                    DropdownMenuItem(value: 'indoor_ac', child: Text('Indoor AC')),
                  ],
                  onChanged: (value) => setState(() => _climate = value ?? 'hot_humid'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _regionController,
                  decoration: const InputDecoration(labelText: 'Region', hintText: 'India, Bengaluru, Delhi...', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _preferencesController,
                  decoration: const InputDecoration(
                    labelText: 'Style preferences/tags',
                    hintText: 'smart casual, minimal, ethnic, budget-conscious',
                    border: OutlineInputBorder(),
                  ),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _budgetConscious,
                  title: const Text('Budget-conscious styling'),
                  subtitle: const Text('Prefer outfits from existing wardrobe over shopping suggestions'),
                  onChanged: (value) => setState(() => _budgetConscious = value),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: state.isBusy ? null : _save,
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('Save profile to backend'),
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
