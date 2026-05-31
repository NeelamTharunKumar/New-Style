import 'package:flutter/material.dart';

import '../../state/app_state.dart';
import '../widgets/status_banner.dart';
import 'ai_stylist_chat.dart';
import 'login_screen.dart';
import 'privacy_settings_screen.dart';
import 'style_profile_screen.dart';
import 'wardrobe_screen.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('BharatFit AI'),
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
                const Text('India-first wardrobe assistant', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text(
                  'Create outfits from your own clothes for college, office, dates, Haldi, Sangeet and weddings. Photos stay on-device; only structured features go to the backend.',
                  style: TextStyle(color: Colors.grey.shade300, height: 1.4),
                ),
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
                _HomeAction(
                  icon: Icons.login_outlined,
                  title: '0. Login & Secure Tokens',
                  subtitle: '${state.authCredentials.authMode} · bearer ${state.authCredentials.hasBearerToken ? 'saved' : 'not set'}',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LoginScreen(appState: state))),
                ),
                _HomeAction(
                  icon: Icons.person_outline,
                  title: '1. Style Profile',
                  subtitle: '${state.profile.userId} · ${state.profile.styleMode} · ${state.profile.skinTone ?? 'skin tone not set'}',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => StyleProfileScreen(appState: state))),
                ),
                _HomeAction(
                  icon: Icons.checkroom_outlined,
                  title: '2. Your Wardrobe',
                  subtitle: '${state.wardrobeItems.length} structured items saved',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => WardrobeScreen(appState: state))),
                ),
                _HomeAction(
                  icon: Icons.auto_awesome_outlined,
                  title: '3. Generate Outfits',
                  subtitle: 'Office, college, date, Haldi, Sangeet, wedding guest and more',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => YourOutfitsScreen(appState: state))),
                ),
                _HomeAction(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy & Local Data',
                  subtitle: 'Export, sync or clear local structured wardrobe data',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PrivacySettingsScreen(appState: state))),
                ),
                _HomeAction(
                  icon: Icons.chat_bubble_outline,
                  title: 'AI Stylist Chat',
                  subtitle: 'Backend chat stub now uses the same privacy-safe API layer',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AIStylistChat(appState: state))),
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
              Text('Backend: ${state.backendHealth}', style: TextStyle(color: Colors.green.shade300)),
            ],
          ],
        ),
      ),
    );
  }
}

class _HomeAction extends StatelessWidget {
  const _HomeAction({required this.icon, required this.title, required this.subtitle, required this.onTap});

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
