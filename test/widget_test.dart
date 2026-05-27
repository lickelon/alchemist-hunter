import 'package:alchemist_hunter/app/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('main tabs are visible', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: App()));

    expect(find.text('마을'), findsOneWidget);
    expect(find.text('작업실'), findsOneWidget);
    expect(find.text('캐릭터'), findsOneWidget);
    expect(find.text('전투'), findsOneWidget);
  });
}
