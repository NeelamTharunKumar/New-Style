import 'package:flutter/material.dart';

import '../../core/design_tokens.dart';

class AppGradientScaffold extends StatelessWidget {
  const AppGradientScaffold({
    super.key,
    this.child,
    this.body,
    this.appBar,
    this.floatingActionButton,
    this.bottomNavigationBar,
  });

  final Widget? child;
  final Widget? body;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;

  @override
  Widget build(BuildContext context) {
    final colors = DrapeColors.of(context);
    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [colors.gradientStart, colors.gradientMid, colors.gradientEnd],
          ),
        ),
        child: body ?? child ?? const SizedBox.shrink(),
      ),
    );
  }
}

class PremiumCard extends StatelessWidget {
  const PremiumCard({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.margin});

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final colors = DrapeColors.of(context);
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: colors.border, width: 1.4),
        boxShadow: AppShadows.cardFor(context),
      ),
      child: child,
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.subtitle, this.action});

  final String title;
  final String? subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final colors = DrapeColors.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900, letterSpacing: -0.5, color: colors.foreground)),
              if (subtitle != null) ...[
                const SizedBox(height: 5),
                Text(subtitle!, style: TextStyle(color: colors.mutedForeground, height: 1.35)),
              ],
            ],
          ),
        ),
        if (action != null) action!,
      ],
    );
  }
}

class StatPill extends StatelessWidget {
  const StatPill({super.key, required this.label, required this.value, this.icon});

  final String label;
  final String value;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colors = DrapeColors.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colors.primarySoft,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 16, color: colors.primary), const SizedBox(width: 6)],
          Text(value, style: TextStyle(fontWeight: FontWeight.w900, color: colors.primary)),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: colors.mutedForeground)),
        ],
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.title, required this.subtitle, this.action});

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final colors = DrapeColors.of(context);
    return PremiumCard(
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: colors.primarySoft,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(icon, size: 38, color: colors.primary),
          ),
          const SizedBox(height: 14),
          Text(title, style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: colors.foreground), textAlign: TextAlign.center),
          const SizedBox(height: 7),
          Text(subtitle, style: TextStyle(color: colors.mutedForeground, height: 1.35), textAlign: TextAlign.center),
          if (action != null) ...[const SizedBox(height: 16), action!],
        ],
      ),
    );
  }
}

class PrivacyBadge extends StatelessWidget {
  const PrivacyBadge({super.key, this.label = 'Photos stay on-device'});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = DrapeColors.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: colors.success.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: colors.success.withValues(alpha: 0.24)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.lock_outline, size: 15, color: colors.success),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: colors.success, fontWeight: FontWeight.w800, fontSize: 12)),
        ],
      ),
    );
  }
}
