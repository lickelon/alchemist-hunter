import 'package:alchemist_hunter/features/battle/presentation/screens/dungeon_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('dungeon screen shows locked reason for later stages', (
    WidgetTester tester,
  ) async {
    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: Scaffold(body: DungeonScreen())),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Stage 2'), findsOneWidget);
    expect(find.text('잠금 조건: 특수 재료 m_30 1개 이상 획득'), findsOneWidget);
    expect(find.text('Locked'), findsWidgets);
  });
}
