import 'package:alchemist_hunter/core/session/session_providers.dart';
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

    expect(find.text('기본 장비 제작'), findsOneWidget);
    expect(find.text('Bronze Sword'), findsOneWidget);
    expect(find.textContaining('Emberroot x2'), findsOneWidget);
    expect(find.text('Iron Buckler'), findsOneWidget);
    expect(find.text('보유 장비가 없습니다'), findsOneWidget);
  });

  testWidgets('crafting from equipment sheet updates inventory', (
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
    await tester.tap(find.widgetWithText(FilledButton, '제작').first);
    await tester.pumpAndSettle();

    expect(session.state.player.gold, 1500);
    expect(session.state.player.materialInventory, isEmpty);
    expect(session.state.town.equipmentInventory.first.name, 'Bronze Sword');
  });
}
