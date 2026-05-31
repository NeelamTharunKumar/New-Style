import 'package:flutter/material.dart';

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
      color: AppColors.primary.withOpacity(0.08),
      blurRadius: 28,
      offset: const Offset(0, 14),
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> accent = [
    BoxShadow(
      color: AppColors.accent.withOpacity(0.24),
      blurRadius: 22,
      offset: const Offset(0, 10),
    ),
  ];
}
