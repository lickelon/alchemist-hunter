import 'package:alchemist_hunter/features/workshop/dashboard/presentation/screens/workshop_screen.dart';
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

    expect(find.text('제작 대기열'), findsOneWidget);
    expect(find.text('재료 추출'), findsOneWidget);
    expect(find.text('연금술'), findsOneWidget);
    expect(find.text('양조'), findsNothing);
    expect(find.text('Logs'), findsNothing);

    final double queueY = tester.getTopLeft(find.text('제작 대기열')).dy;
    final double extractionY = tester.getTopLeft(find.text('재료 추출')).dy;
    final double craftY = tester.getTopLeft(find.text('연금술')).dy;

    expect(queueY, lessThan(extractionY));
    expect(extractionY, lessThan(craftY));

    await tester.scrollUntilVisible(
      find.text('작업실 보관함'),
      120,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('작업실 보관함'), findsOneWidget);
  });
}
