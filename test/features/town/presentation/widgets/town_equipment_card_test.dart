import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/town/presentation/widgets/town_equipment_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('town equipment sheet shows craftable blueprints', (
    WidgetTester tester,
  ) async {
    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);
    final SessionController session = container.read(
      sessionControllerProvider.notifier,
    );
    session.state = session.state.copyWith(
      player: session.state.player.copyWith(
        materialInventory: const <String, int>{'m_1': 2, 'm_2': 1},
      ),
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(body: TownEquipmentCraftCard(equipmentCount: 0)),
        ),
      ),
    );

    await tester.tap(find.text('Equipment Craft'));
    await tester.pumpAndSettle();

    expect(find.text('대장간'), findsOneWidget);
    expect(find.text('Bronze Sword'), findsOneWidget);
    expect(find.textContaining('Emberroot x2'), findsOneWidget);
    expect(find.text('Iron Buckler'), findsOneWidget);
    expect(find.textContaining('제작 시간 30s'), findsAtLeastNWidgets(1));
    expect(find.text('보유 장비가 없습니다'), findsOneWidget);
  });

  testWidgets('crafting from equipment sheet enqueues forge job', (
    WidgetTester tester,
  ) async {
    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);

    final SessionController session = container.read(
      sessionControllerProvider.notifier,
    );
    session.state = session.state.copyWith(
      player: session.state.player.copyWith(
        materialInventory: const <String, int>{'m_1': 2, 'm_2': 1},
      ),
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(body: TownEquipmentCraftCard(equipmentCount: 0)),
        ),
      ),
    );

    await tester.tap(find.text('Equipment Craft'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '등록').first);
    await tester.pumpAndSettle();

    expect(session.state.player.gold, 1500);
    expect(session.state.player.materialInventory, isEmpty);
    expect(session.state.town.equipmentInventory, isEmpty);
    expect(session.state.town.forgeQueue.first.name, 'Bronze Sword');
  });
}
