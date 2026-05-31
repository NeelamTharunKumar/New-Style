import 'package:flutter_test/flutter_test.dart';
import 'package:bharatfit_ai/data/app_models.dart';

void main() {
  group('WardrobeItem', () {
    test('round-trips structured privacy-safe data', () {
      const item = WardrobeItem(
        userId: 'u1',
        itemId: 'shirt_001',
        styleMode: 'menswear',
        name: 'Light blue office shirt',
        category: 'shirt',
        color: 'light blue',
        hexColor: '#A8C7E8',
        fabric: 'cotton',
        occasionTags: ['office'],
        localImageRef: 'local://wardrobe/shirt_001.jpg',
        featureVectorSummary: {
          'dominant_color_name': 'light blue',
          'privacy': 'computed on-device; raw image not uploaded',
        },
      );

      final json = item.toJson();
      expect(json['local_image_ref'], 'local://wardrobe/shirt_001.jpg');
      expect(json['feature_vector_summary'], isA<Map<String, dynamic>>());

      final parsed = WardrobeItem.fromJson(json);
      expect(parsed.itemId, 'shirt_001');
      expect(parsed.displayName, 'Light blue office shirt');
      expect(parsed.featureVectorSummary['dominant_color_name'], 'light blue');
    });
  });

  group('splitTags', () {
    test('normalizes, deduplicates and sorts tags', () {
      expect(splitTags('Office, office, Haldi,  smart casual '), ['haldi', 'office', 'smart casual']);
    });
  });
}
