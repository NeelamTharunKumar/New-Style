import 'package:flutter/material.dart';

import '../../core/design_tokens.dart';
import '../../data/app_models.dart';
import '../../state/app_state.dart';
import '../widgets/app_components.dart';
import '../widgets/local_wardrobe_image.dart';
import '../widgets/status_banner.dart';

class OutfitPreviewScreen extends StatefulWidget {
  const OutfitPreviewScreen({super.key, required this.appState, required this.outfit, this.occasion});

  final AppState appState;
  final OutfitRecommendation outfit;
  final String? occasion;

  @override
  State<OutfitPreviewScreen> createState() => _OutfitPreviewScreenState();
}

class _OutfitPreviewScreenState extends State<OutfitPreviewScreen> {
  bool _mannequinMode = true;

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

  Future<void> _feedback({bool worn = false, bool favorite = false, bool rejected = false}) async {
    await widget.appState.recordOutfitFeedback(
      outfit: widget.outfit,
      occasion: widget.occasion,
      rating: rejected ? 1 : 5,
      worn: worn,
      favorite: favorite,
      rejected: rejected,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.appState;
    final items = widget.outfit.itemIds.map(state.itemById).whereType<WardrobeItem>().toList();
    return AppGradientScaffold(
      appBar: AppBar(title: const Text('Preview Look')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          StatusBanner(error: state.error, message: state.statusMessage, isBusy: state.isBusy),
          PremiumCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.outfit.title,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, height: 1.05),
                      ),
                    ),
                    const PrivacyBadge(label: 'Generated locally'),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'A local mannequin-style preview to help you judge the outfit before swapping. This is not a body-accurate try-on.',
                  style: TextStyle(color: DrapeColors.of(context).mutedForeground, height: 1.35),
                ),
                const SizedBox(height: 14),
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(value: true, icon: Icon(Icons.accessibility_new), label: Text('Mannequin')),
                    ButtonSegment(value: false, icon: Icon(Icons.dashboard_customize_outlined), label: Text('Board')),
                  ],
                  selected: {_mannequinMode},
                  onSelectionChanged: (values) => setState(() => _mannequinMode = values.first),
                ),
                const SizedBox(height: 16),
                _mannequinMode ? _MannequinPreview(items: items) : _BoardPreview(items: items),
              ],
            ),
          ),
          const SizedBox(height: 16),
          PremiumCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(
                  title: 'Actions',
                  subtitle: 'Your feedback improves future outfit ranking. No photos are uploaded.',
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilledButton.icon(
                      onPressed: state.isBusy ? null : () => _feedback(worn: true),
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Wear today'),
                    ),
                    OutlinedButton.icon(
                      onPressed: state.isBusy ? null : () => _feedback(favorite: true),
                      icon: const Icon(Icons.bookmark_border),
                      label: const Text('Save'),
                    ),
                    OutlinedButton.icon(
                      onPressed: state.isBusy ? null : () => state.generateOutfits(occasion: widget.occasion ?? 'daily casual'),
                      icon: const Icon(Icons.swap_horiz),
                      label: const Text('Swap item'),
                    ),
                    OutlinedButton.icon(
                      onPressed: state.isBusy ? null : () => _feedback(rejected: true),
                      icon: const Icon(Icons.thumb_down_alt_outlined),
                      label: const Text('Not my style'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MannequinPreview extends StatelessWidget {
  const _MannequinPreview({required this.items});

  final List<WardrobeItem> items;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 0.68,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight;
          return Container(
            decoration: BoxDecoration(
              color: DrapeColors.of(context).muted,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: DrapeColors.of(context).border),
            ),
            child: Stack(
              children: [
                Positioned.fill(child: CustomPaint(painter: _MannequinPainter())),
                ...items.map((item) => _positionedItem(item, w, h)),
                Positioned(
                  left: 14,
                  right: 14,
                  bottom: 12,
                  child: Text(
                    'Preview uses local item images and approximate slots — not an exact fit simulation.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: DrapeColors.of(context).mutedForeground.withValues(alpha: 0.9), fontSize: 12),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _positionedItem(WardrobeItem item, double w, double h) {
    final slot = _slotForCategory(item.category);
    final rect = slot.rect(w, h);
    return Positioned(
      left: rect.left,
      top: rect.top,
      width: rect.width,
      height: rect.height,
      child: _PreviewGarment(item: item, slot: slot),
    );
  }
}

class _BoardPreview extends StatelessWidget {
  const _BoardPreview({required this.items});

  final List<WardrobeItem> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const EmptyState(
        icon: Icons.checkroom_outlined,
        title: 'No local item images found',
        subtitle: 'Add wardrobe items with local photos to preview this look.',
      );
    }
    return Column(
      children: items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  LocalWardrobeImage(localImageRef: item.localImageRef, hexColor: item.hexColor, width: 74, height: 74, borderRadius: 18),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.displayName, style: const TextStyle(fontWeight: FontWeight.w900)),
                        Text(item.category, style: TextStyle(color: DrapeColors.of(context).mutedForeground)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _PreviewGarment extends StatelessWidget {
  const _PreviewGarment({required this.item, required this.slot});

  final WardrobeItem item;
  final _PreviewSlot slot;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: slot.rotation,
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: DrapeColors.of(context).surface.withValues(alpha: 0.82),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: DrapeColors.of(context).border),
          boxShadow: AppShadows.cardFor(context),
        ),
        child: Column(
          children: [
            Expanded(
              child: LocalWardrobeImage(
                localImageRef: item.localImageRef,
                hexColor: item.hexColor,
                borderRadius: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              item.category,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewSlot {
  const _PreviewSlot(this.left, this.top, this.width, this.height, {this.rotation = 0});

  final double left;
  final double top;
  final double width;
  final double height;
  final double rotation;

  Rect rect(double w, double h) => Rect.fromLTWH(left * w, top * h, width * w, height * h);
}

_PreviewSlot _slotForCategory(String category) {
  final c = category.toLowerCase();
  if ({'shirt', 't-shirt', 'polo', 'top', 'blouse'}.contains(c)) return const _PreviewSlot(0.25, 0.22, 0.50, 0.23);
  if ({'kurti', 'kurta', 'anarkali', 'sherwani', 'dress', 'kurta set'}.contains(c)) return const _PreviewSlot(0.22, 0.20, 0.56, 0.38);
  if ({'saree', 'lehenga'}.contains(c)) return const _PreviewSlot(0.16, 0.18, 0.68, 0.48);
  if ({'dupatta', 'jacket', 'nehru jacket', 'ethnic jacket', 'blazer'}.contains(c)) return const _PreviewSlot(0.14, 0.23, 0.72, 0.18, rotation: -0.08);
  if ({'jeans', 'chinos', 'trousers', 'trouser', 'palazzo', 'leggings', 'skirt', 'salwar', 'churidar', 'dhoti'}.contains(c)) return const _PreviewSlot(0.28, 0.48, 0.44, 0.30);
  if ({'sneakers', 'sneaker', 'loafers', 'formal shoes', 'shoes', 'sandals', 'heels', 'juttis', 'flats'}.contains(c)) return const _PreviewSlot(0.30, 0.80, 0.40, 0.13);
  if ({'watch', 'belt', 'jewelry', 'handbag', 'bag', 'earrings', 'necklace', 'grooming'}.contains(c)) return const _PreviewSlot(0.68, 0.34, 0.22, 0.16, rotation: 0.10);
  return const _PreviewSlot(0.36, 0.36, 0.28, 0.20);
}

class _MannequinPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;
    final stroke = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final center = Offset(size.width / 2, size.height * 0.12);
    canvas.drawCircle(center, size.width * 0.09, paint);
    canvas.drawCircle(center, size.width * 0.09, stroke);

    final body = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(size.width / 2, size.height * 0.37), width: size.width * 0.38, height: size.height * 0.34),
      const Radius.circular(90),
    );
    canvas.drawRRect(body, paint);
    canvas.drawRRect(body, stroke);

    final leftLeg = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.35, size.height * 0.52, size.width * 0.11, size.height * 0.30),
      const Radius.circular(40),
    );
    final rightLeg = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.54, size.height * 0.52, size.width * 0.11, size.height * 0.30),
      const Radius.circular(40),
    );
    canvas.drawRRect(leftLeg, paint);
    canvas.drawRRect(rightLeg, paint);
    canvas.drawRRect(leftLeg, stroke);
    canvas.drawRRect(rightLeg, stroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
