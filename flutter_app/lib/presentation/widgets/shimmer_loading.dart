import 'package:flutter/material.dart';

import '../../core/design_tokens.dart';

// ────────────────────────────────────────────────────────────────────────────
// Core shimmer effect — a gradient sweep animation applied to child shapes.
// Built with pure Flutter, no external packages needed.
// ────────────────────────────────────────────────────────────────────────────

class ShimmerEffect extends StatefulWidget {
  const ShimmerEffect({super.key, required this.child});

  final Widget child;

  @override
  State<ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<ShimmerEffect> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = DrapeColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final baseColor = isDark ? colors.muted : colors.border.withValues(alpha: 0.5);
    final highlightColor = isDark ? colors.surface : Colors.white.withValues(alpha: 0.9);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [baseColor, highlightColor, baseColor],
              stops: [
                (_controller.value - 0.3).clamp(0.0, 1.0),
                _controller.value,
                (_controller.value + 0.3).clamp(0.0, 1.0),
              ],
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Reusable shimmer bone — a single rounded rectangle placeholder.
// ────────────────────────────────────────────────────────────────────────────

class ShimmerBone extends StatelessWidget {
  const ShimmerBone({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius = 8,
  });

  final double? width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final colors = DrapeColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDark ? colors.muted : colors.border.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Skeleton: Outfit card — mimics the shape of _OutfitCard in your_outfits_screen
// ────────────────────────────────────────────────────────────────────────────

class ShimmerOutfitCard extends StatelessWidget {
  const ShimmerOutfitCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = DrapeColors.of(context);
    return ShimmerEffect(
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AppRadii.card),
          border: Border.all(color: colors.border, width: 1.4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row with score pill
            const Row(
              children: [
                Expanded(child: ShimmerBone(height: 22, borderRadius: 6)),
                SizedBox(width: 16),
                ShimmerBone(width: 44, height: 28, borderRadius: 99),
              ],
            ),
            const SizedBox(height: 14),
            // Item tiles row
            SizedBox(
              height: 116,
              child: Row(
                children: List.generate(3, (index) => Padding(
                  padding: EdgeInsets.only(right: index < 2 ? 10 : 0),
                  child: Container(
                    width: 132,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: colors.border),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShimmerBone(width: double.infinity, height: 42, borderRadius: 10),
                        SizedBox(height: 8),
                        ShimmerBone(width: 80, height: 14),
                        Spacer(),
                        ShimmerBone(width: 60, height: 10),
                      ],
                    ),
                  ),
                )),
              ),
            ),
            const SizedBox(height: 14),
            // Why text placeholder
            const ShimmerBone(height: 14),
            const SizedBox(height: 6),
            const ShimmerBone(width: 240, height: 14),
            const SizedBox(height: 6),
            const ShimmerBone(width: 180, height: 14),
            const SizedBox(height: 14),
            // Styling tips header
            const ShimmerBone(width: 100, height: 16, borderRadius: 6),
            const SizedBox(height: 8),
            const ShimmerBone(width: 200, height: 12),
            const SizedBox(height: 4),
            const ShimmerBone(width: 220, height: 12),
            const SizedBox(height: 14),
            // Score breakdown chips
            const Row(
              children: [
                ShimmerBone(width: 80, height: 30, borderRadius: 99),
                SizedBox(width: 8),
                ShimmerBone(width: 100, height: 30, borderRadius: 99),
                SizedBox(width: 8),
                ShimmerBone(width: 70, height: 30, borderRadius: 99),
              ],
            ),
            const SizedBox(height: 14),
            // Action buttons row
            const ShimmerBone(width: 64, height: 16, borderRadius: 6),
            const SizedBox(height: 8),
            const Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ShimmerBone(width: 120, height: 36, borderRadius: 20),
                ShimmerBone(width: 100, height: 36, borderRadius: 20),
                ShimmerBone(width: 70, height: 36, borderRadius: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// A list of shimmer outfit cards to show while generating outfits.
class ShimmerOutfitList extends StatelessWidget {
  const ShimmerOutfitList({super.key, this.count = 3});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(count, (_) => const ShimmerOutfitCard()),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Skeleton: Wardrobe grid card — mimics _WardrobeGridCard
// ────────────────────────────────────────────────────────────────────────────

class ShimmerWardrobeGrid extends StatelessWidget {
  const ShimmerWardrobeGrid({super.key, this.count = 4});

  final int count;

  @override
  Widget build(BuildContext context) {
    return ShimmerEffect(
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.78,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: count,
        itemBuilder: (context, index) => const _ShimmerWardrobeGridCard(),
      ),
    );
  }
}

class _ShimmerWardrobeGridCard extends StatelessWidget {
  const _ShimmerWardrobeGridCard();

  @override
  Widget build(BuildContext context) {
    final colors = DrapeColors.of(context);
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: colors.border, width: 1.4),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ShimmerBone(
              width: double.infinity,
              height: double.infinity,
              borderRadius: 16,
            ),
          ),
          SizedBox(height: 10),
          ShimmerBone(width: 100, height: 14),
          SizedBox(height: 4),
          ShimmerBone(width: 70, height: 11),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Shimmer status banner — replaces CircularProgressIndicator in StatusBanner
// ────────────────────────────────────────────────────────────────────────────

class ShimmerPulseIndicator extends StatefulWidget {
  const ShimmerPulseIndicator({super.key, this.size = 16, required this.color});

  final double size;
  final Color color;

  @override
  State<ShimmerPulseIndicator> createState() => _ShimmerPulseIndicatorState();
}

class _ShimmerPulseIndicatorState extends State<ShimmerPulseIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: 0.3 + (_controller.value * 0.7),
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: widget.color,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.auto_awesome, size: widget.size * 0.65, color: Colors.white),
          ),
        );
      },
    );
  }
}
