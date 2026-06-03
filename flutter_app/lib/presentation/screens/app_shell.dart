import 'package:flutter/material.dart';

import '../../core/design_tokens.dart';
import '../../state/app_state.dart';
import 'home_dashboard.dart';
import 'wardrobe_screen.dart';
import 'your_outfits_screen.dart';
import 'login_screen.dart';
import 'style_profile_screen.dart';
import 'privacy_settings_screen.dart';
import 'ai_stylist_chat.dart';

/// Main app shell with persistent bottom navigation.
class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.appState});

  final AppState appState;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

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

  @override
  Widget build(BuildContext context) {
    final state = widget.appState;
    final colors = DrapeColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeDashboard(appState: state),
          WardrobeScreen(appState: state),
          YourOutfitsScreen(appState: state),
          _SettingsTab(appState: state),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          border: Border(top: BorderSide(color: colors.border, width: 1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: [
                _NavItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home_rounded,
                  label: 'Home',
                  isActive: _currentIndex == 0,
                  colors: colors,
                  onTap: () => setState(() => _currentIndex = 0),
                ),
                _NavItem(
                  icon: Icons.checkroom_outlined,
                  activeIcon: Icons.checkroom,
                  label: 'Wardrobe',
                  isActive: _currentIndex == 1,
                  colors: colors,
                  onTap: () => setState(() => _currentIndex = 1),
                ),
                _NavItem(
                  icon: Icons.auto_awesome_outlined,
                  activeIcon: Icons.auto_awesome,
                  label: 'Outfits',
                  isActive: _currentIndex == 2,
                  colors: colors,
                  onTap: () => setState(() => _currentIndex = 2),
                ),
                _NavItem(
                  icon: Icons.settings_outlined,
                  activeIcon: Icons.settings,
                  label: 'Settings',
                  isActive: _currentIndex == 3,
                  colors: colors,
                  onTap: () => setState(() => _currentIndex = 3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom bottom nav item with animated indicator.
class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.colors,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final DrapeColors colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                padding: EdgeInsets.symmetric(
                  horizontal: isActive ? 20 : 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isActive ? colors.primarySoft : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                ),
                child: Icon(
                  isActive ? activeIcon : icon,
                  size: 24,
                  color: isActive ? colors.primary : colors.mutedForeground,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isActive ? FontWeight.w800 : FontWeight.w500,
                  color: isActive ? colors.primary : colors.mutedForeground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Settings tab — groups login, profile, privacy, AI chat, and theme toggle.
class _SettingsTab extends StatelessWidget {
  const _SettingsTab({required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    final colors = DrapeColors.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [colors.gradientStart, colors.gradientMid, colors.gradientEnd],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            // ── Theme toggle card ──
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.palette_outlined, color: colors.primary),
                        const SizedBox(width: 10),
                        Text('Appearance', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: colors.foreground)),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        _ThemeOption(
                          icon: Icons.brightness_auto,
                          label: 'System',
                          isSelected: appState.themeMode == ThemeMode.system,
                          colors: colors,
                          onTap: () => appState.setThemeMode(ThemeMode.system),
                        ),
                        const SizedBox(width: 10),
                        _ThemeOption(
                          icon: Icons.light_mode,
                          label: 'Light',
                          isSelected: appState.themeMode == ThemeMode.light,
                          colors: colors,
                          onTap: () => appState.setThemeMode(ThemeMode.light),
                        ),
                        const SizedBox(width: 10),
                        _ThemeOption(
                          icon: Icons.dark_mode,
                          label: 'Dark',
                          isSelected: appState.themeMode == ThemeMode.dark,
                          colors: colors,
                          onTap: () => appState.setThemeMode(ThemeMode.dark),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            // ── Navigation items ──
            _SettingsTile(
              icon: Icons.login_outlined,
              title: 'Login & Secure Tokens',
              subtitle: '${appState.authCredentials.authMode} · bearer ${appState.authCredentials.hasBearerToken ? "saved" : "not set"}',
              colors: colors,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LoginScreen(appState: appState))),
            ),
            _SettingsTile(
              icon: Icons.person_outline,
              title: 'Style Profile',
              subtitle: '${appState.profile.userId} · ${appState.profile.styleMode}',
              colors: colors,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => StyleProfileScreen(appState: appState))),
            ),
            _SettingsTile(
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy & Local Data',
              subtitle: 'Export, sync or clear local data',
              colors: colors,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PrivacySettingsScreen(appState: appState))),
            ),
            _SettingsTile(
              icon: Icons.chat_bubble_outline,
              title: 'AI Stylist Chat',
              subtitle: 'Privacy-safe chat with backend',
              colors: colors,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AIStylistChat(appState: appState))),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: appState.resetOnboarding,
              icon: const Icon(Icons.restart_alt),
              label: const Text('Replay onboarding'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.colors,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final DrapeColors colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? colors.primarySoft : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadii.control),
            border: Border.all(
              color: isSelected ? colors.primary : colors.border,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? colors.primary : colors.mutedForeground, size: 26),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                  color: isSelected ? colors.primary : colors.mutedForeground,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.colors,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final DrapeColors colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: colors.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle, style: TextStyle(color: colors.mutedForeground)),
        trailing: Icon(Icons.chevron_right, color: colors.mutedForeground),
        onTap: onTap,
      ),
    );
  }
}
