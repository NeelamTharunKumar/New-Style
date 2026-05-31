import 'package:flutter_test/flutter_test.dart';
import 'package:drape_ai/core/branding.dart';

void main() {
  test('brand constants are production-ready defaults', () {
    expect(AppBranding.appName, 'Drape AI');
    expect(AppBranding.androidApplicationId, 'com.drape.ai');
    expect(AppBranding.iosBundleId, 'com.drape.ai');
    expect(AppBranding.privacyPromise, contains('Photos'));
  });
}
