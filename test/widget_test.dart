import 'package:alchemist_hunter/app/app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('main tabs are visible', (WidgetTester tester) async {
    await tester.pumpWidget(const App());

    expect(find.text('Characters'), findsOneWidget);
    expect(find.text('Weapons'), findsOneWidget);
    expect(find.text('Dungeons'), findsOneWidget);
    expect(find.text('Pets'), findsOneWidget);
  });
}
