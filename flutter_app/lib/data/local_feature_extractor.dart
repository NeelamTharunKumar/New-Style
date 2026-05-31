import 'dart:io';
import 'dart:math';

import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

import 'local_image_service.dart';

class ExtractedGarmentFeatures {
  const ExtractedGarmentFeatures({
    required this.localImageRef,
    required this.hexColor,
    required this.colorName,
    required this.patternHint,
    required this.brightness,
    required this.confidence,
    required this.width,
    required this.height,
  });

  final String localImageRef;
  final String hexColor;
  final String colorName;
  final String patternHint;
  final double brightness;
  final double confidence;
  final int width;
  final int height;

  Map<String, dynamic> toStructuredSummary() {
    return {
      'local_extraction': true,
      'dominant_hex_color': hexColor,
      'dominant_color_name': colorName,
      'pattern_hint': patternHint,
      'brightness': brightness,
      'confidence': confidence,
      'image_width': width,
      'image_height': height,
      'privacy': 'computed on-device; raw image not uploaded',
    };
  }
}

class LocalFeatureExtractor {
  LocalFeatureExtractor({LocalImageService? imageService}) : imageService = imageService ?? const LocalImageService();

  final LocalImageService imageService;
  final ImagePicker _picker = ImagePicker();

  Future<ExtractedGarmentFeatures?> pickCopyAndExtract({required String itemIdHint}) async {
    final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 92);
    if (picked == null) return null;
    final localRef = await imageService.copyImageIntoWardrobe(picked.path, itemIdHint: itemIdHint);
    return extractFromLocalRef(localRef);
  }

  Future<ExtractedGarmentFeatures> extractFromLocalRef(String localImageRef) async {
    final path = imageService.pathFromLocalRef(localImageRef);
    if (path == null) {
      throw StateError('Unsupported local image reference: $localImageRef');
    }
    final bytes = await File(path).readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      throw StateError('Could not decode selected image');
    }

    final sample = decoded.width > 320 ? img.copyResize(decoded, width: 320) : decoded;
    final stats = _dominantColorStats(sample);
    final hex = _rgbToHex(stats.r, stats.g, stats.b);
    final name = _nameColor(stats.r, stats.g, stats.b);
    final pattern = _patternHint(stats.luminanceVariance);
    final confidence = _confidence(stats.sampleCount, stats.clusterShare, stats.luminanceVariance);

    return ExtractedGarmentFeatures(
      localImageRef: localImageRef,
      hexColor: hex,
      colorName: name,
      patternHint: pattern,
      brightness: stats.averageLuminance,
      confidence: confidence,
      width: decoded.width,
      height: decoded.height,
    );
  }

  _ColorStats _dominantColorStats(img.Image image) {
    final buckets = <int, _Bucket>{};
    final luminanceValues = <double>[];
    final step = max(1, sqrt((image.width * image.height) / 5000).round());

    for (var y = 0; y < image.height; y += step) {
      for (var x = 0; x < image.width; x += step) {
        final pixel = image.getPixel(x, y);
        final r = pixel.r.toInt();
        final g = pixel.g.toInt();
        final b = pixel.b.toInt();
        final a = pixel.a.toInt();
        if (a < 180) continue;

        final lum = _luminance(r, g, b);
        // Ignore near-white backgrounds and near-black shadows for a better clothing estimate.
        if (lum > 244 || lum < 8) continue;

        final rq = (r ~/ 32) * 32;
        final gq = (g ~/ 32) * 32;
        final bq = (b ~/ 32) * 32;
        final key = (rq << 16) + (gq << 8) + bq;
        final bucket = buckets.putIfAbsent(key, () => _Bucket());
        bucket
          ..count += 1
          ..r += r
          ..g += g
          ..b += b;
        luminanceValues.add(lum);
      }
    }

    if (buckets.isEmpty) {
      return const _ColorStats(r: 128, g: 128, b: 128, sampleCount: 0, clusterShare: 0, averageLuminance: 128, luminanceVariance: 0);
    }

    final dominant = buckets.values.reduce((a, b) => a.count >= b.count ? a : b);
    final total = buckets.values.fold<int>(0, (sum, bucket) => sum + bucket.count);
    final avgLum = luminanceValues.fold<double>(0, (sum, value) => sum + value) / max(1, luminanceValues.length);
    final variance = luminanceValues.fold<double>(0, (sum, value) => sum + pow(value - avgLum, 2).toDouble()) / max(1, luminanceValues.length);

    return _ColorStats(
      r: (dominant.r / dominant.count).round(),
      g: (dominant.g / dominant.count).round(),
      b: (dominant.b / dominant.count).round(),
      sampleCount: total,
      clusterShare: dominant.count / max(1, total),
      averageLuminance: avgLum,
      luminanceVariance: variance,
    );
  }

  String _patternHint(double variance) {
    if (variance > 3200) return 'patterned';
    if (variance > 1800) return 'subtle texture';
    return 'solid';
  }

  double _confidence(int sampleCount, double clusterShare, double variance) {
    if (sampleCount == 0) return 0.1;
    final sampleScore = min(1.0, sampleCount / 2500);
    final clusterScore = min(1.0, clusterShare * 2.2);
    final variancePenalty = variance > 5000 ? 0.2 : 0.0;
    return (0.35 + sampleScore * 0.35 + clusterScore * 0.3 - variancePenalty).clamp(0.1, 0.95).toDouble();
  }
}

class _Bucket {
  int count = 0;
  int r = 0;
  int g = 0;
  int b = 0;
}

class _ColorStats {
  const _ColorStats({
    required this.r,
    required this.g,
    required this.b,
    required this.sampleCount,
    required this.clusterShare,
    required this.averageLuminance,
    required this.luminanceVariance,
  });

  final int r;
  final int g;
  final int b;
  final int sampleCount;
  final double clusterShare;
  final double averageLuminance;
  final double luminanceVariance;
}

double _luminance(int r, int g, int b) => 0.2126 * r + 0.7152 * g + 0.0722 * b;

String _rgbToHex(int r, int g, int b) {
  String part(int value) => value.clamp(0, 255).toInt().toRadixString(16).padLeft(2, '0').toUpperCase();
  return '#${part(r)}${part(g)}${part(b)}';
}

String _nameColor(int r, int g, int b) {
  final candidates = <String, List<int>>{
    'black': [20, 20, 20],
    'white': [245, 245, 240],
    'cream': [238, 226, 198],
    'beige': [198, 173, 125],
    'brown': [115, 75, 45],
    'tan': [184, 132, 82],
    'grey': [128, 128, 128],
    'charcoal': [54, 61, 68],
    'navy blue': [24, 43, 88],
    'blue': [50, 105, 190],
    'light blue': [150, 190, 225],
    'green': [48, 130, 76],
    'olive': [104, 122, 52],
    'emerald green': [0, 135, 95],
    'yellow': [230, 200, 55],
    'mustard yellow': [205, 150, 35],
    'orange': [220, 115, 35],
    'red': [185, 45, 45],
    'maroon': [110, 30, 45],
    'pink': [220, 120, 160],
    'purple': [120, 75, 170],
    'gold': [210, 165, 55],
  };

  var best = 'neutral';
  var bestDistance = double.infinity;
  for (final entry in candidates.entries) {
    final c = entry.value;
    final distance = pow(r - c[0], 2) + pow(g - c[1], 2) + pow(b - c[2], 2);
    if (distance < bestDistance) {
      bestDistance = distance.toDouble();
      best = entry.key;
    }
  }
  return best;
}
