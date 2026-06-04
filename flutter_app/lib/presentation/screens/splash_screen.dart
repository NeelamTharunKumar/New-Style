import 'package:flutter/material.dart';

import '../../core/branding.dart';
import '../../core/design_tokens.dart';
import '../widgets/brand_mark.dart';
import '../widgets/shimmer_loading.dart';

/// Branded splash screen shown while the app hydrates local state.
/// Displays the Drape AI logo with a pulsing glow animation, the app name,
/// and the tagline — all on a gradient background.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _pulseAnim;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = DrapeColors.of(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colors.gradientStart,
              colors.gradientMid,
              colors.gradientEnd,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 3),

              // ── Pulsing logo ──
              ScaleTransition(
                scale: _pulseAnim,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: colors.primary.withValues(alpha: 0.3),
                        blurRadius: 40,
                        spreadRadius: 8,
                      ),
                    ],
                  ),
                  child: const BrandMark(size: 96),
                ),
              ),
              const SizedBox(height: 28),

              // ── App name ──
              SlideTransition(
                position: _slideAnim,
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: Text(
                    AppBranding.appName,
                    style: TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.w900,
                      color: colors.foreground,
                      letterSpacing: -1.2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // ── Tagline ──
              SlideTransition(
                position: _slideAnim,
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: Text(
                    AppBranding.tagline,
                    style: TextStyle(
                      fontSize: 16,
                      color: colors.mutedForeground,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),

              const Spacer(flex: 2),

              // ── Loading indicator ──
              ShimmerEffect(
                child: Container(
                  width: 120,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Loading your wardrobe…',
                style: TextStyle(
                  fontSize: 13,
                  color: colors.mutedForeground.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),

              const Spacer(flex: 1),

              // ── Privacy badge at bottom ──
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock_outline, size: 14, color: colors.success.withValues(alpha: 0.7)),
                    const SizedBox(width: 6),
                    Text(
                      AppBranding.privacyPromise,
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.success.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
