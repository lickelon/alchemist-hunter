import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/town/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/presentation/widgets/workshop_enchant_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('workshop enchant sheet enqueues enchant job', (
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
            attack: 12,
            defense: 0,
            health: 0,
            createdAt: DateTime(2026, 1, 1, 10),
          ),
        ],
      ),
      workshop: session.state.workshop.copyWith(
        craftedPotionStacks: const <String, int>{'p_1|a': 1},
        craftedPotionDetails: <String, CraftedPotion>{
          'p_1|a': CraftedPotion(
            id: 'cp_1',
            typePotionId: 'p_1',
            qualityGrade: PotionQualityGrade.a,
            qualityScore: 0.84,
            traits: const <String, double>{'t_atk': 0.7, 't_hp': 0.3},
            createdAt: DateTime(2026, 1, 1, 10),
          ),
        },
      ),
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(
            body: WorkshopEnchantCard(potionStackCount: 1, equipmentCount: 1),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Enchant'));
    await tester.pumpAndSettle();

    expect(
      find.text('포션과 장비를 선택하면 인챈트 결과를 미리 볼 수 있습니다'),
      findsOneWidget,
    );

    await tester.tap(find.byType(RadioListTile<String>).at(0));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(RadioListTile<String>).at(1));
    await tester.pumpAndSettle();
    expect(find.text('예상 결과'), findsOneWidget);
    expect(find.text('현재 인챈트 없음'), findsOneWidget);
    expect(find.text('예상 Potion 1 A'), findsOneWidget);
    expect(find.textContaining('변화 ATK +13'), findsOneWidget);
    await tester.tap(find.text('인챈트 등록'));
    await tester.pumpAndSettle();

    expect(session.state.workshop.craftedPotionStacks, isEmpty);
    expect(session.state.town.equipmentInventory, isEmpty);
    expect(session.state.workshop.queue, hasLength(1));
    expect(session.state.workshop.queue.first.type, WorkshopJobType.enchant);
    expect(
      session.state.workshop.queue.first.completedEquipment?.enchant?.label,
      'Potion 1 A',
    );
  });

  testWidgets('workshop enchant sheet confirms replacement before overwrite', (
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
            attack: 12,
            defense: 0,
            health: 0,
            createdAt: DateTime(2026, 1, 1, 10),
            enchant: const EquipmentEnchant(
              potionStackKey: 'p_old|b',
              potionName: 'Old Brew',
              qualityLabel: 'B',
              dominantTraitId: 't_def',
              attackBonus: 2,
              defenseBonus: 3,
              healthBonus: 4,
            ),
          ),
        ],
      ),
      workshop: session.state.workshop.copyWith(
        craftedPotionStacks: const <String, int>{'p_1|a': 1},
        craftedPotionDetails: <String, CraftedPotion>{
          'p_1|a': CraftedPotion(
            id: 'cp_1',
            typePotionId: 'p_1',
            qualityGrade: PotionQualityGrade.a,
            qualityScore: 0.84,
            traits: const <String, double>{'t_atk': 0.7, 't_hp': 0.3},
            createdAt: DateTime(2026, 1, 1, 10),
          ),
        },
      ),
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(
            body: WorkshopEnchantCard(potionStackCount: 1, equipmentCount: 1),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Enchant'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(RadioListTile<String>).at(0));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(RadioListTile<String>).at(1));
    await tester.pumpAndSettle();

    expect(find.text('기존 인챈트가 교체됩니다'), findsOneWidget);
    expect(find.text('현재 Old Brew B'), findsOneWidget);
    expect(find.text('예상 Potion 1 A'), findsOneWidget);
    expect(find.text('인챈트 교체 등록'), findsOneWidget);

    await tester.tap(find.text('인챈트 교체 등록'));
    await tester.pumpAndSettle();

    expect(find.text('기존 인챈트 교체'), findsOneWidget);
    expect(find.text('교체'), findsOneWidget);
    await tester.tap(find.text('취소'));
    await tester.pumpAndSettle();

    expect(session.state.workshop.craftedPotionStacks['p_1|a'], 1);
    expect(
      session.state.town.equipmentInventory.first.enchant?.label,
      'Old Brew B',
    );

    await tester.tap(find.text('인챈트 교체 등록'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('교체'));
    await tester.pumpAndSettle();

    expect(session.state.workshop.craftedPotionStacks, isEmpty);
    expect(session.state.town.equipmentInventory, isEmpty);
    expect(session.state.workshop.queue, hasLength(1));
    expect(
      session.state.workshop.queue.first.completedEquipment?.enchant?.label,
      'Potion 1 A',
    );
  });
}
