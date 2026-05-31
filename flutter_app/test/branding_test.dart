import 'package:flutter_test/flutter_test.dart';
import 'package:bharatfit_ai/core/branding.dart';

void main() {
  test('brand constants are production-ready defaults', () {
    expect(AppBranding.appName, 'BharatFit AI');
    expect(AppBranding.androidApplicationId, 'com.bharatfit.ai');
    expect(AppBranding.iosBundleId, 'com.bharatfit.ai');
    expect(AppBranding.privacyPromise, contains('Photos'));
  });
}
