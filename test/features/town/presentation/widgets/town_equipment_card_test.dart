import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/town/domain/models.dart';
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
          home: Scaffold(body: TownEquipmentCraftCard()),
        ),
      ),
    );

    await tester.tap(find.text('장비 제작'));
    await tester.pumpAndSettle();

    expect(find.text('대장간'), findsOneWidget);
    expect(find.text('Bronze Sword'), findsOneWidget);
    expect(find.textContaining('Emberroot x2'), findsOneWidget);
    expect(find.text('Iron Buckler'), findsOneWidget);
    expect(find.textContaining('제작 시간 30s'), findsAtLeastNWidgets(1));
    await tester.scrollUntilVisible(
      find.text('보유 장비가 없습니다'),
      120,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
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
          home: Scaffold(body: TownEquipmentCraftCard()),
        ),
      ),
    );

    await tester.tap(find.text('장비 제작'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '등록').first);
    await tester.pumpAndSettle();

    expect(session.state.player.gold, 1500);
    expect(session.state.player.materialInventory, isEmpty);
    expect(session.state.town.equipmentInventory, isEmpty);
    expect(session.state.town.forgeQueue.first.name, 'Bronze Sword');
  });

  testWidgets('town equipment inventory opens item detail from grid', (
    WidgetTester tester,
  ) async {
    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);

    final SessionController session = container.read(
      sessionControllerProvider.notifier,
    );
    session.state = session.state.copyWith(
      town: session.state.town.copyWith(
        equipmentInventory: <EquipmentInstance>[
          EquipmentInstance(
            id: 'eq_instance_1',
            blueprintId: 'eq_1',
            name: 'Bronze Sword',
            slot: EquipmentSlot.weapon,
            physicalAttack: 12,
            createdAt: DateTime(2026, 1, 1, 10),
          ),
        ],
      ),
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(body: TownEquipmentCraftCard()),
        ),
      ),
    );

    await tester.tap(find.text('장비 제작'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey<String>('town_equipment_eq_instance_1')),
      120,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const ValueKey<String>('town_equipment_eq_instance_1')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Bronze Sword'), findsAtLeastNWidgets(1));
    expect(find.text('슬롯 무기'), findsOneWidget);
    expect(find.textContaining('물공 12'), findsOneWidget);
  });
}
