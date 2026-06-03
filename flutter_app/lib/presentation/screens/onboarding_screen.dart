import 'package:flutter/material.dart';

import '../../core/design_tokens.dart';

import '../../core/branding.dart';
import '../../state/app_state.dart';
import '../widgets/app_components.dart';
import '../widgets/brand_mark.dart';
import 'app_shell.dart';
import 'login_screen.dart';
import 'splash_screen.dart';
import 'style_profile_screen.dart';
import 'wardrobe_screen.dart';

class OnboardingGate extends StatefulWidget {
  const OnboardingGate({super.key, required this.appState});

  final AppState appState;

  @override
  State<OnboardingGate> createState() => _OnboardingGateState();
}

class _OnboardingGateState extends State<OnboardingGate> {
  bool _splashDone = false;

  @override
  void initState() {
    super.initState();
    widget.appState.addListener(_refresh);
    WidgetsBinding.instance.addPostFrameCallback((_) => _initApp());
  }

  Future<void> _initApp() async {
    // Run hydration and a minimum splash timer in parallel.
    // The splash stays visible until BOTH complete.
    await Future.wait([
      widget.appState.hydrate(),
      Future.delayed(const Duration(seconds: 2)),
    ]);
    if (mounted) {
      setState(() => _splashDone = true);
    }
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
    if (!_splashDone) {
      return const SplashScreen();
    }
    if (!state.hasCompletedOnboarding) {
      return OnboardingScreen(appState: state);
    }
    return AppShell(appState: state);
  }
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.appState});

  final AppState appState;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await widget.appState.completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      const _OnboardingPage(
        icon: Icons.checkroom_outlined,
        title: 'Your Indian wardrobe, finally understood',
        subtitle: 'Mix ethnic and western pieces for college, office, dates, Haldi, Sangeet, weddings and everyday looks.',
      ),
      const _OnboardingPage(
        icon: Icons.lock_outline,
        title: 'Privacy-first by design',
        subtitle: 'Wardrobe photos stay on your device. The backend receives item IDs, colors, categories and tags — not raw images.',
      ),
      const _OnboardingPage(
        icon: Icons.auto_awesome_outlined,
        title: 'Outfits from clothes you already own',
        subtitle: 'Generate exact outfit combinations with local image previews, explanations, climate context and styling tips.',
      ),
    ];

    return AppGradientScaffold(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  const PrivacyBadge(),
                  const Spacer(),
                  TextButton(onPressed: _finish, child: const Text('Skip')),
                ],
              ),
              Expanded(
                child: PageView(
                  controller: _controller,
                  onPageChanged: (value) => setState(() => _index = value),
                  children: pages,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  pages.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    width: i == _index ? 24 : 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: i == _index ? Theme.of(context).colorScheme.primary : DrapeColors.of(context).border,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (_index < pages.length - 1) {
                      _controller.nextPage(duration: const Duration(milliseconds: 260), curve: Curves.easeOut);
                    } else {
                      _finish();
                    }
                  },
                  icon: Icon(_index < pages.length - 1 ? Icons.arrow_forward : Icons.done),
                  label: Text(_index < pages.length - 1 ? 'Continue' : 'Enter ${AppBranding.shortName}'),
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LoginScreen(appState: widget.appState))),
                    child: const Text('Login'),
                  ),
                  OutlinedButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => StyleProfileScreen(appState: widget.appState))),
                    child: const Text('Profile'),
                  ),
                  OutlinedButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => WardrobeScreen(appState: widget.appState))),
                    child: const Text('Wardrobe'),
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

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({required this.icon, required this.title, required this.subtitle});

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 24),
          PremiumCard(
            padding: const EdgeInsets.all(24),
            child: icon == Icons.checkroom_outlined
                ? const BrandMark(size: 72)
                : Icon(icon, size: 64, color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(height: 24),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, height: 1.08)),
          const SizedBox(height: 10),
          Text(subtitle, textAlign: TextAlign.center, style: TextStyle(color: DrapeColors.of(context).mutedForeground, fontSize: 15, height: 1.45)),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
