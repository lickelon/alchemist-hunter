import 'dart:math';

import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/battle/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/data/repositories/static_potion_catalog_repository.dart';
import 'package:alchemist_hunter/features/workshop/data/repositories/static_workshop_skill_tree_repository.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/domain/services/potion_crafting_service.dart';
import 'package:alchemist_hunter/features/workshop/domain/services/workshop_support_service.dart';
import 'package:alchemist_hunter/features/workshop/domain/services/workshop_skill_tree_service.dart';
import 'package:alchemist_hunter/features/workshop/presentation/viewmodels/craft_queue_controller.dart';
import 'package:alchemist_hunter/features/workshop/presentation/viewmodels/craft_queue/craft_queue_option_selectors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  SessionController buildSession() {
    return SessionController(clock: () => DateTime(2026, 1, 1, 10));
  }

  WorkshopCraftQueueController buildController(
    SessionController session, {
    int craftingSeed = 13,
  }) {
    return WorkshopCraftQueueController(
      session,
      PotionCraftingService(random: Random(craftingSeed)),
      potionCatalogRepository: const StaticPotionCatalogRepository(),
      workshopSkillTreeRepository: const StaticWorkshopSkillTreeRepository(),
      workshopSkillTreeService: const WorkshopSkillTreeService(),
      workshopSupportService: const WorkshopSupportService(),
    );
  }

  test('enqueuePotion reserves extracted traits and adds craft job', () {
    final SessionController session = buildSession();
    session.state = session.state.copyWith(
      workshop: session.state.workshop.copyWith(
        extractedTraitInventory: const <String, double>{
          't_hp': 1.2,
          't_atk': 0.8,
        },
      ),
    );
    final WorkshopCraftQueueController controller = buildController(
      session,
      craftingSeed: 5,
    );

    controller.enqueuePotion('p_1', 2);

    expect(session.state.workshop.queue, hasLength(1));
    expect(session.state.workshop.queue.single.type, WorkshopJobType.craft);
    expect(session.state.workshop.queue.single.repeatCount, 2);
    expect(session.state.workshop.queue.single.status, QueueJobStatus.processing);
    expect(session.state.workshop.extractedTraitInventory, isEmpty);
    expect(session.state.workshop.logs.first, '제조 등록 / p_1 x2');
  });

  test('claimJob applies only selected completed potion job', () {
    final SessionController session = buildSession();
    final WorkshopCraftQueueController controller = buildController(session);
    session.state = session.state.copyWith(
      workshop: session.state.workshop.copyWith(
        queue: <CraftQueueJob>[
          CraftQueueJob(
            id: 'job_extract',
            type: WorkshopJobType.extraction,
            status: QueueJobStatus.completed,
            queuedAt: DateTime(2026, 1, 1, 10),
            duration: const Duration(seconds: 10),
            eta: Duration.zero,
            title: 'Emberroot',
            materialId: 'm_1',
            quantity: 1,
            completedExtractedTraits: const <String, double>{'t_hp': 0.5},
            completedArcaneDust: 2,
          ),
          CraftQueueJob(
            id: 'job_craft',
            type: WorkshopJobType.craft,
            status: QueueJobStatus.completed,
            queuedAt: DateTime(2026, 1, 1, 10),
            duration: const Duration(seconds: 10),
            eta: Duration.zero,
            title: 'Potion 1',
            potionId: 'p_1',
            repeatCount: 2,
            completedPotionStackKey: 'p_1|a',
            completedPotion: CraftedPotion(
              id: 'cp_1',
              typePotionId: 'p_1',
              qualityGrade: PotionQualityGrade.a,
              qualityScore: 0.84,
              traits: const <String, double>{'t_atk': 0.7, 't_hp': 0.3},
              createdAt: DateTime(2026, 1, 1, 10),
            ),
          ),
        ],
      ),
    );

    controller.claimJob('job_craft');

    expect(session.state.workshop.queue, hasLength(1));
    expect(session.state.workshop.queue.single.id, 'job_extract');
    expect(session.state.player.arcaneDust, 2);
    expect(session.state.workshop.craftedPotionStacks['p_1|a'], 2);
    expect(session.state.workshop.potionCraftCount, 2);
    expect(session.state.workshop.extractionCount, 0);
    expect(session.state.workshop.logs.first, '큐 작업 수령 / job_craft');
  });

  test('claimJob applies only selected completed extraction job', () {
    final SessionController session = buildSession();
    final WorkshopCraftQueueController controller = buildController(session);
    session.state = session.state.copyWith(
      workshop: session.state.workshop.copyWith(
        queue: <CraftQueueJob>[
          CraftQueueJob(
            id: 'job_extract',
            type: WorkshopJobType.extraction,
            status: QueueJobStatus.completed,
            queuedAt: DateTime(2026, 1, 1, 10),
            duration: const Duration(seconds: 10),
            eta: Duration.zero,
            title: 'Emberroot',
            materialId: 'm_1',
            quantity: 1,
            completedExtractedTraits: const <String, double>{'t_hp': 0.5},
            completedArcaneDust: 2,
          ),
          CraftQueueJob(
            id: 'job_craft',
            type: WorkshopJobType.craft,
            status: QueueJobStatus.completed,
            queuedAt: DateTime(2026, 1, 1, 10),
            duration: const Duration(seconds: 10),
            eta: Duration.zero,
            title: 'Potion 1',
            potionId: 'p_1',
            repeatCount: 2,
            completedPotionStackKey: 'p_1|a',
            completedPotion: CraftedPotion(
              id: 'cp_1',
              typePotionId: 'p_1',
              qualityGrade: PotionQualityGrade.a,
              qualityScore: 0.84,
              traits: const <String, double>{'t_atk': 0.7, 't_hp': 0.3},
              createdAt: DateTime(2026, 1, 1, 10),
            ),
          ),
        ],
      ),
    );

    controller.claimJob('job_extract');

    expect(session.state.workshop.queue, hasLength(1));
    expect(session.state.workshop.queue.single.id, 'job_craft');
    expect(session.state.player.arcaneDust, 4);
    expect(session.state.workshop.extractedTraitInventory['t_hp'], 0.5);
    expect(session.state.workshop.extractionCount, 1);
    expect(session.state.workshop.logs.first, '큐 작업 수령 / job_extract');
  });

  test('enqueuePotion is blocked when queue is full', () {
    final SessionController session = buildSession();
    final WorkshopCraftQueueController controller = buildController(session);
    final DateTime now = DateTime(2026, 1, 1, 10);
    session.state = session.state.copyWith(
      workshop: session.state.workshop.copyWith(
        extractedTraitInventory: const <String, double>{
          't_hp': 4.8,
          't_atk': 3.2,
        },
        queue: List<CraftQueueJob>.generate(
          4,
          (int index) => CraftQueueJob(
            id: 'job_$index',
            type: WorkshopJobType.craft,
            status: QueueJobStatus.queued,
            queuedAt: now,
            duration: const Duration(seconds: 15),
            eta: const Duration(seconds: 15),
            title: 'Potion 1',
            potionId: 'p_1',
          ),
        ),
      ),
    );

    controller.enqueuePotion('p_1', 1);

    expect(session.state.workshop.queue, hasLength(4));
    expect(session.state.workshop.logs.first, '작업실 큐 가득 참 / p_1 x1');
  });

  test(
    'workshop queue option views reflect unlock flags and inventory count',
    () {
      final ProviderContainer container = ProviderContainer();
      addTearDown(container.dispose);

      final SessionController session = container.read(
        sessionControllerProvider.notifier,
      );
      session.state = session.state.copyWith(
        workshop: session.state.workshop.copyWith(
          extractedTraitInventory: const <String, double>{
            't_hp': 2.4,
            't_atk': 1.6,
          },
        ),
        battle: session.state.battle.copyWith(
          progress: ProgressState(
            unlockFlags: <String>{'stage_1', 'potion_special_1'},
            automationTier: session.state.battle.progress.automationTier,
            sessionPhase: session.state.battle.progress.sessionPhase,
          ),
        ),
      );

      final List<PotionQueueOptionView> options = container.read(
        workshopPotionQueueOptionViewsProvider,
      );

      final PotionQueueOptionView basePotion = options.firstWhere(
        (PotionQueueOptionView option) => option.potionId == 'p_1',
      );
      final PotionQueueOptionView specialPotion = options.firstWhere(
        (PotionQueueOptionView option) => option.potionId == 'p_11',
      );
      final PotionQueueOptionView lockedPotion = options.firstWhere(
        (PotionQueueOptionView option) => option.potionId == 'p_14',
      );

      expect(basePotion.unlocked, true);
      expect(basePotion.craftableNow, true);
      expect(basePotion.maxCraftableCount, greaterThanOrEqualTo(1));
      expect(specialPotion.unlocked, true);
      expect(lockedPotion.unlocked, false);
      expect(lockedPotion.lockReason, '특수 재료 Moontear Crystal 드롭 필요');
    },
  );
}
