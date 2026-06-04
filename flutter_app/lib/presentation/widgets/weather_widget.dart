import 'package:flutter/material.dart';

import '../../core/design_tokens.dart';
import '../../data/weather_service.dart';
import '../../state/app_state.dart';
import 'shimmer_loading.dart';

// ────────────────────────────────────────────────────────────────────────────
// WeatherWidget — a beautiful, glassmorphism-style card showing live weather.
// Displays on the Home Dashboard and informs the AI outfit engine.
// ────────────────────────────────────────────────────────────────────────────

class WeatherWidget extends StatelessWidget {
  const WeatherWidget({super.key, required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    if (appState.isWeatherLoading) {
      return const _ShimmerWeatherCard();
    }

    final weather = appState.currentWeather;
    if (weather == null) {
      return _WeatherUnavailableCard(onRetry: appState.fetchWeather);
    }

    return _LiveWeatherCard(weather: weather, onRefresh: appState.fetchWeather);
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Live weather card — shows temperature, condition, city, and AI hint.
// ────────────────────────────────────────────────────────────────────────────

class _LiveWeatherCard extends StatelessWidget {
  const _LiveWeatherCard({required this.weather, required this.onRefresh});

  final WeatherData weather;
  final VoidCallback onRefresh;

  String get _aiHint {
    final temp = weather.temperatureC;
    if (temp >= 35) return 'Drape will suggest lightweight, breathable outfits 👕';
    if (temp >= 28) return 'Drape will pick comfortable, weather-smart looks 🌿';
    if (temp >= 18) return 'Drape will recommend layered, versatile outfits 🧥';
    return 'Drape will suggest warm, cozy combinations 🧣';
  }

  @override
  Widget build(BuildContext context) {
    final colors = DrapeColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(
          color: colors.primary.withValues(alpha: 0.18),
          width: 1.4,
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  colors.surface,
                  colors.primary.withValues(alpha: 0.08),
                ]
              : [
                  Colors.white.withValues(alpha: 0.9),
                  colors.primarySoft.withValues(alpha: 0.6),
                ],
        ),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top row: icon + temp + condition + refresh ──
          Row(
            children: [
              // Animated weather icon
              _GlowingWeatherIcon(icon: weather.icon),
              const SizedBox(width: 14),
              // Temperature
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${weather.temperatureC.round()}°C',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: colors.foreground,
                            height: 1.0,
                            letterSpacing: -1,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              weather.description.isNotEmpty 
                                  ? '${weather.description} · ${weather.humidity}% humidity'
                                  : '${weather.humidity}% humidity',
                              style: TextStyle(
                                fontSize: 13,
                                color: colors.mutedForeground,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Refresh button
              IconButton(
                onPressed: onRefresh,
                icon: Icon(Icons.refresh_rounded, size: 20, color: colors.mutedForeground),
                tooltip: 'Refresh weather',
                style: IconButton.styleFrom(
                  backgroundColor: colors.muted.withValues(alpha: 0.5),
                  minimumSize: const Size(36, 36),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ── City row ──
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: 15, color: colors.primary.withValues(alpha: 0.7)),
              const SizedBox(width: 4),
              Text(
                weather.city,
                style: TextStyle(
                  fontSize: 13,
                  color: colors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          // ── Divider ──
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colors.border.withValues(alpha: 0.0),
                    colors.border,
                    colors.border.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),

          // ── AI hint ──
          Text(
            _aiHint,
            style: TextStyle(
              fontSize: 13,
              color: colors.mutedForeground,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Glowing weather icon with pulse animation.
// ────────────────────────────────────────────────────────────────────────────

class _GlowingWeatherIcon extends StatefulWidget {
  const _GlowingWeatherIcon({required this.icon});

  final String icon;

  @override
  State<_GlowingWeatherIcon> createState() => _GlowingWeatherIconState();
}

class _GlowingWeatherIconState extends State<_GlowingWeatherIcon> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _glowAnim = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
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
    return AnimatedBuilder(
      animation: _glowAnim,
      builder: (context, child) {
        return Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colors.primarySoft,
            boxShadow: [
              BoxShadow(
                color: colors.primary.withValues(alpha: _glowAnim.value * 0.25),
                blurRadius: 16,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Center(
            child: Text(
              widget.icon,
              style: const TextStyle(fontSize: 28),
            ),
          ),
        );
      },
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Shimmer loading state for weather card.
// ────────────────────────────────────────────────────────────────────────────

class _ShimmerWeatherCard extends StatelessWidget {
  const _ShimmerWeatherCard();

  @override
  Widget build(BuildContext context) {
    final colors = DrapeColors.of(context);
    return ShimmerEffect(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AppRadii.card),
          border: Border.all(color: colors.border, width: 1.4),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ShimmerBone(width: 56, height: 56, borderRadius: 28),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerBone(width: 100, height: 28),
                      SizedBox(height: 6),
                      ShimmerBone(width: 180, height: 13),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            ShimmerBone(width: 120, height: 13),
            SizedBox(height: 16),
            ShimmerBone(height: 1),
            SizedBox(height: 16),
            ShimmerBone(width: 260, height: 13),
          ],
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Weather unavailable / permission denied state.
// ────────────────────────────────────────────────────────────────────────────

class _WeatherUnavailableCard extends StatelessWidget {
  const _WeatherUnavailableCard({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = DrapeColors.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: colors.border, width: 1.4),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.muted,
            ),
            child: Center(
              child: Icon(Icons.location_off_outlined, size: 22, color: colors.mutedForeground),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Weather unavailable',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: colors.foreground,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Grant location access for climate-smart outfits',
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
