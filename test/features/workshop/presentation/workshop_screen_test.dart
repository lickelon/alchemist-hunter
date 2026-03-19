import 'package:alchemist_hunter/features/workshop/presentation/screens/workshop_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('workshop screen prioritizes queue and inventory cards', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: Scaffold(body: WorkshopScreen())),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Craft Queue'), findsOneWidget);
    expect(find.text('Extraction'), findsOneWidget);
    expect(find.text('Craft'), findsOneWidget);
    expect(find.text('Items'), findsNothing);
    expect(find.text('Crafted Potions'), findsNothing);
    expect(find.text('Logs'), findsNothing);

    final double queueY = tester.getTopLeft(find.text('Craft Queue')).dy;
    final double extractionY = tester.getTopLeft(find.text('Extraction')).dy;
    final double craftY = tester.getTopLeft(find.text('Craft')).dy;

    expect(queueY, lessThan(extractionY));
    expect(extractionY, lessThan(craftY));

    await tester.scrollUntilVisible(
      find.text('Inventory'),
      120,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('Inventory'), findsOneWidget);
  });
}
