import 'package:alchemist_hunter/app/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('main tabs are visible', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: App()));

    expect(find.text('Town'), findsOneWidget);
    expect(find.text('Workshop'), findsOneWidget);
    expect(find.text('Characters'), findsOneWidget);
    expect(find.text('Battle'), findsOneWidget);
  });
}
