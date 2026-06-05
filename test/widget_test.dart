import 'package:alchemist_hunter/app/main_tab_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('main tabs are visible', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: DefaultTabController(
          length: 4,
          child: Scaffold(bottomNavigationBar: MainTabBar()),
        ),
      ),
    );

    expect(find.text('마을'), findsOneWidget);
    expect(find.text('작업실'), findsOneWidget);
    expect(find.text('캐릭터'), findsOneWidget);
    expect(find.text('전투'), findsOneWidget);
  });
}
