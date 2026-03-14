import 'package:alchemist_hunter/core/session/session_providers.dart';
import 'package:alchemist_hunter/features/town/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/presentation/widgets/workshop_enchant_card.dart';
import 'package:alchemist_hunter/features/workshop/presentation/widgets/workshop_extraction_card.dart';
import 'package:alchemist_hunter/features/workshop/presentation/widgets/workshop_material_card.dart';
import 'package:alchemist_hunter/features/workshop/presentation/widgets/workshop_queue_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('workshop queue sheet shows blocked state and resume action', (
    WidgetTester tester,
  ) async {
    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);

    final SessionController session = container.read(
      sessionControllerProvider.notifier,
    );
    session.state = session.state.copyWith(
      player: session.state.player.copyWith(),
      workshop: session.state.workshop.copyWith(
        extractedTraitInventory: const <String, double>{
          't_hp': 0.6,
          't_atk': 0.4,
        },
        queue: <CraftQueueJob>[
          const CraftQueueJob(
            id: 'job_1',
            potionId: 'p_1',
            repeatCount: 1,
            retryPolicy: CraftRetryPolicy(maxRetries: 2),
            status: QueueJobStatus.blocked,
            eta: Duration.zero,
          ),
        ],
      ),
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(body: WorkshopQueueCard(jobCount: 1)),
        ),
      ),
    );

    await tester.tap(find.text('Craft Queue'));
    await tester.pumpAndSettle();

    expect(find.text('재개'), findsOneWidget);
    expect(find.text('Potion 1 0/1'), findsOneWidget);
    expect(find.text('상태 진행 불가, 추출 특성 보충 후 재개 가능'), findsOneWidget);
  });

  testWidgets('workshop material sheet shows material name and trait summary', (
    WidgetTester tester,
  ) async {
    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);

    final SessionController session = container.read(
      sessionControllerProvider.notifier,
    );
    session.state = session.state.copyWith(
      player: session.state.player.copyWith(
        materialInventory: const <String, int>{'m_1': 2},
      ),
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(
            body: WorkshopMaterialCard(materialTypeCount: 1, totalCount: 2),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Items'));
    await tester.pumpAndSettle();

    expect(find.text('Emberroot'), findsOneWidget);
    expect(find.text('common / Vital / Swift'), findsOneWidget);
    expect(find.text('x2'), findsOneWidget);
  });

  testWidgets(
    'workshop queue sheet shows clear completed button and missing materials',
    (WidgetTester tester) async {
      final ProviderContainer container = ProviderContainer();
      addTearDown(container.dispose);

      final SessionController session = container.read(
        sessionControllerProvider.notifier,
      );
      session.state = session.state.copyWith(
        player: session.state.player.copyWith(
          materialInventory: const <String, int>{'m_1': 1},
        ),
        workshop: session.state.workshop.copyWith(
          extractedTraitInventory: const <String, double>{'t_hp': 0.2},
          queue: <CraftQueueJob>[
            const CraftQueueJob(
              id: 'job_done',
              potionId: 'p_1',
              repeatCount: 1,
              retryPolicy: CraftRetryPolicy(maxRetries: 2),
              status: QueueJobStatus.completed,
              eta: Duration.zero,
              currentRepeat: 1,
            ),
            const CraftQueueJob(
              id: 'job_blocked',
              potionId: 'p_1',
              repeatCount: 1,
              retryPolicy: CraftRetryPolicy(maxRetries: 2),
              status: QueueJobStatus.blocked,
              eta: Duration.zero,
            ),
          ],
        ),
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(body: WorkshopQueueCard(jobCount: 2)),
          ),
        ),
      );

      await tester.tap(find.text('Craft Queue'));
      await tester.pumpAndSettle();

      expect(find.text('완료 정리 (1)'), findsOneWidget);
      expect(find.textContaining('부족 특성:'), findsOneWidget);
      expect(find.text('Potion 1 0/1'), findsOneWidget);
      expect(find.text('Potion 1 1/1'), findsOneWidget);
    },
  );

  testWidgets(
    'workshop extraction sheet shows trait stock and extraction actions',
    (WidgetTester tester) async {
      final ProviderContainer container = ProviderContainer();
      addTearDown(container.dispose);

      final SessionController session = container.read(
        sessionControllerProvider.notifier,
      );
      session.state = session.state.copyWith(
        player: session.state.player.copyWith(
          materialInventory: const <String, int>{'m_1': 2},
        ),
        workshop: session.state.workshop.copyWith(
          extractedTraitInventory: const <String, double>{'t_hp': 0.85},
        ),
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: WorkshopExtractionCard(
                materialTypeCount: 1,
                extractedTraitTypeCount: 1,
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Extraction'));
      await tester.pumpAndSettle();

      expect(find.text('보유 추출 특성'), findsOneWidget);
      expect(find.textContaining('Vital 0.85'), findsOneWidget);
      expect(find.text('분석/추출'), findsOneWidget);

      await tester.tap(find.text('분석/추출'));
      await tester.pumpAndSettle();

      expect(find.text('보유 2개'), findsOneWidget);
      expect(find.text('추출 수량'), findsOneWidget);
      expect(find.text('최대'), findsOneWidget);
    },
  );

  testWidgets('workshop enchant sheet consumes potion and applies enchant', (
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

    expect(find.text('포션과 장비를 선택하면 인챈트 결과를 미리 볼 수 있습니다'), findsOneWidget);

    await tester.tap(find.byType(RadioListTile<String>).at(0));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(RadioListTile<String>).at(1));
    await tester.pumpAndSettle();
    expect(find.text('예상 결과'), findsOneWidget);
    expect(find.text('현재 인챈트 없음'), findsOneWidget);
    expect(find.text('예상 Potion 1 A'), findsOneWidget);
    expect(find.textContaining('변화 ATK +13'), findsOneWidget);
    await tester.tap(find.text('인챈트 실행'));
    await tester.pumpAndSettle();

    expect(session.state.workshop.craftedPotionStacks, isEmpty);
    expect(
      session.state.town.equipmentInventory.first.enchant?.label,
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
    expect(find.text('인챈트 교체'), findsOneWidget);

    await tester.tap(find.text('인챈트 교체'));
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

    await tester.tap(find.text('인챈트 교체'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('교체'));
    await tester.pumpAndSettle();

    expect(session.state.workshop.craftedPotionStacks, isEmpty);
    expect(
      session.state.town.equipmentInventory.first.enchant?.label,
      'Potion 1 A',
    );
  });
}
