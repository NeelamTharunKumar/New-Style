import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bharatfit_ai/presentation/widgets/app_components.dart';
import 'package:bharatfit_ai/presentation/widgets/brand_mark.dart';

void main() {
  testWidgets('PrivacyBadge communicates local-photo privacy', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: PrivacyBadge()),
      ),
    );

    expect(find.text('Photos stay on-device'), findsOneWidget);
    expect(find.byIcon(Icons.lock_outline), findsOneWidget);
  });

  testWidgets('BrandMark renders without layout errors', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Center(child: BrandMark(size: 64))),
      ),
    );

    expect(find.byType(BrandMark), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('EmptyState shows title, subtitle and action', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EmptyState(
            icon: Icons.checkroom_outlined,
            title: 'No wardrobe items yet',
            subtitle: 'Add your first item.',
            action: ElevatedButton(onPressed: () {}, child: const Text('Add item')),
          ),
        ),
      ),
    );

    expect(find.text('No wardrobe items yet'), findsOneWidget);
    expect(find.text('Add your first item.'), findsOneWidget);
    expect(find.text('Add item'), findsOneWidget);
  });
}
