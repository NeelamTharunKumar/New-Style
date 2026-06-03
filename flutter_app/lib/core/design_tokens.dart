import 'package:flutter/material.dart';

/// Theme-aware color system for Drape AI.
///
/// Usage: `DrapeColors.of(context).primary` or the legacy static
/// `AppColors.primary` (still available for const contexts / design tokens
/// that don't change between themes).
@immutable
class DrapeColors extends ThemeExtension<DrapeColors> {
  const DrapeColors({
    required this.primary,
    required this.primarySoft,
    required this.secondary,
    required this.accent,
    required this.accentSoft,
    required this.background,
    required this.backgroundAlt,
    required this.foreground,
    required this.muted,
    required this.mutedForeground,
    required this.border,
    required this.surface,
    required this.success,
    required this.destructive,
    required this.ring,
    required this.gradientStart,
    required this.gradientMid,
    required this.gradientEnd,
  });

  final Color primary;
  final Color primarySoft;
  final Color secondary;
  final Color accent;
  final Color accentSoft;
  final Color background;
  final Color backgroundAlt;
  final Color foreground;
  final Color muted;
  final Color mutedForeground;
  final Color border;
  final Color surface;
  final Color success;
  final Color destructive;
  final Color ring;
  final Color gradientStart;
  final Color gradientMid;
  final Color gradientEnd;

  // ── Light palette ────────────────────────────────────────────
  static const light = DrapeColors(
    primary: Color(0xFFBE185D),
    primarySoft: Color(0xFFFCE7F3),
    secondary: Color(0xFFEC4899),
    accent: Color(0xFFD97706),
    accentSoft: Color(0xFFFFF7ED),
    background: Color(0xFFFDF2F8),
    backgroundAlt: Color(0xFFFFFBFD),
    foreground: Color(0xFF0F172A),
    muted: Color(0xFFFBF1F5),
    mutedForeground: Color(0xFF64748B),
    border: Color(0xFFF7E3EB),
    surface: Color(0xFFFFFFFF),
    success: Color(0xFF15803D),
    destructive: Color(0xFFDC2626),
    ring: Color(0xFFBE185D),
    gradientStart: Color(0xFFFDF2F8),
    gradientMid: Color(0xFFFFFBFD),
    gradientEnd: Color(0xFFFFF7ED),
  );

  // ── Dark palette ─────────────────────────────────────────────
  static const dark = DrapeColors(
    primary: Color(0xFFF472B6),
    primarySoft: Color(0xFF3B1133),
    secondary: Color(0xFFF9A8D4),
    accent: Color(0xFFFBBF24),
    accentSoft: Color(0xFF2A1F0A),
    background: Color(0xFF0F0F14),
    backgroundAlt: Color(0xFF161620),
    foreground: Color(0xFFF1F5F9),
    muted: Color(0xFF1E1E2A),
    mutedForeground: Color(0xFF94A3B8),
    border: Color(0xFF2A2A3A),
    surface: Color(0xFF1A1A26),
    success: Color(0xFF4ADE80),
    destructive: Color(0xFFEF4444),
    ring: Color(0xFFF472B6),
    gradientStart: Color(0xFF0F0F14),
    gradientMid: Color(0xFF161620),
    gradientEnd: Color(0xFF1A1520),
  );

  /// Convenience accessor from any widget build method.
  static DrapeColors of(BuildContext context) {
    return Theme.of(context).extension<DrapeColors>() ?? light;
  }

  @override
  DrapeColors copyWith({
    Color? primary,
    Color? primarySoft,
    Color? secondary,
    Color? accent,
    Color? accentSoft,
    Color? background,
    Color? backgroundAlt,
    Color? foreground,
    Color? muted,
    Color? mutedForeground,
    Color? border,
    Color? surface,
    Color? success,
    Color? destructive,
    Color? ring,
    Color? gradientStart,
    Color? gradientMid,
    Color? gradientEnd,
  }) {
    return DrapeColors(
      primary: primary ?? this.primary,
      primarySoft: primarySoft ?? this.primarySoft,
      secondary: secondary ?? this.secondary,
      accent: accent ?? this.accent,
      accentSoft: accentSoft ?? this.accentSoft,
      background: background ?? this.background,
      backgroundAlt: backgroundAlt ?? this.backgroundAlt,
      foreground: foreground ?? this.foreground,
      muted: muted ?? this.muted,
      mutedForeground: mutedForeground ?? this.mutedForeground,
      border: border ?? this.border,
      surface: surface ?? this.surface,
      success: success ?? this.success,
      destructive: destructive ?? this.destructive,
      ring: ring ?? this.ring,
      gradientStart: gradientStart ?? this.gradientStart,
      gradientMid: gradientMid ?? this.gradientMid,
      gradientEnd: gradientEnd ?? this.gradientEnd,
    );
  }

  @override
  DrapeColors lerp(DrapeColors? other, double t) {
    if (other is! DrapeColors) return this;
    return DrapeColors(
      primary: Color.lerp(primary, other.primary, t)!,
      primarySoft: Color.lerp(primarySoft, other.primarySoft, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentSoft: Color.lerp(accentSoft, other.accentSoft, t)!,
      background: Color.lerp(background, other.background, t)!,
      backgroundAlt: Color.lerp(backgroundAlt, other.backgroundAlt, t)!,
      foreground: Color.lerp(foreground, other.foreground, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      mutedForeground: Color.lerp(mutedForeground, other.mutedForeground, t)!,
      border: Color.lerp(border, other.border, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      success: Color.lerp(success, other.success, t)!,
      destructive: Color.lerp(destructive, other.destructive, t)!,
      ring: Color.lerp(ring, other.ring, t)!,
      gradientStart: Color.lerp(gradientStart, other.gradientStart, t)!,
      gradientMid: Color.lerp(gradientMid, other.gradientMid, t)!,
      gradientEnd: Color.lerp(gradientEnd, other.gradientEnd, t)!,
    );
  }
}

/// Legacy static accessor — kept for backward compatibility in code that
/// cannot call `DrapeColors.of(context)` (e.g. const constructors, theme
/// building). For runtime widget code, prefer `DrapeColors.of(context)`.
class AppColors {
  const AppColors._();

  static const primary = Color(0xFFBE185D);
  static const primarySoft = Color(0xFFFCE7F3);
  static const secondary = Color(0xFFEC4899);
  static const accent = Color(0xFFD97706);
  static const accentSoft = Color(0xFFFFF7ED);
  static const background = Color(0xFFFDF2F8);
  static const backgroundAlt = Color(0xFFFFFBFD);
  static const foreground = Color(0xFF0F172A);
  static const muted = Color(0xFFFBF1F5);
  static const mutedForeground = Color(0xFF64748B);
  static const border = Color(0xFFF7E3EB);
  static const surface = Color(0xFFFFFFFF);
  static const success = Color(0xFF15803D);
  static const destructive = Color(0xFFDC2626);
  static const ring = Color(0xFFBE185D);
}

class AppRadii {
  const AppRadii._();

  static const double card = 28;
  static const double control = 18;
  static const double pill = 999;
}

class AppShadows {
  const AppShadows._();

  static List<BoxShadow> card = [
    BoxShadow(
      color: AppColors.primary.withValues(alpha: 0.08),
      blurRadius: 28,
      offset: const Offset(0, 14),
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> cardDark = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.28),
      blurRadius: 28,
      offset: const Offset(0, 14),
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.18),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> accent = [
    BoxShadow(
      color: AppColors.accent.withValues(alpha: 0.24),
      blurRadius: 22,
      offset: const Offset(0, 10),
    ),
  ];

  /// Pick the right shadow set based on brightness.
  static List<BoxShadow> cardFor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? cardDark : card;
  }
}
