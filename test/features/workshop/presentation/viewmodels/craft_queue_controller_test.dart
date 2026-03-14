import 'dart:math';

import 'package:alchemist_hunter/core/session/session_providers.dart';
import 'package:alchemist_hunter/features/battle/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/presentation/viewmodels/craft_queue_controller.dart';
import 'package:alchemist_hunter/features/workshop/presentation/viewmodels/craft_queue_selectors.dart';
import 'package:alchemist_hunter/features/workshop/domain/services/craft_queue_service.dart';
import 'package:alchemist_hunter/features/workshop/domain/services/potion_crafting_service.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';
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
      CraftQueueService(),
      PotionCraftingService(random: Random(craftingSeed)),
    );
  }

  test('tickCraftQueue consumes inventory and produces crafted potions', () {
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

    controller.enqueuePotion('p_1', 1);
    controller.tickCraftQueue();

    expect(
      session.state.workshop.queue.single.status,
      QueueJobStatus.completed,
    );
    expect(
      session.state.workshop.craftedPotionStacks.values.fold<int>(
        0,
        (int sum, int value) => sum + value,
      ),
      1,
    );
    expect(session.state.workshop.craftedPotionDetails, isNotEmpty);
    expect(
      session.state.workshop.extractedTraitInventory['t_hp'],
      closeTo(0.6, 0.0001),
    );
    expect(
      session.state.workshop.extractedTraitInventory['t_atk'],
      closeTo(0.4, 0.0001),
    );
    expect(
      session.state.workshop.logs.first,
      'Processed queue tick / produced 1',
    );
  });

  test('enqueuePotion is blocked when materials are missing', () {
    final SessionController session = buildSession();
    final WorkshopCraftQueueController controller = buildController(
      session,
      craftingSeed: 5,
    );

    controller.enqueuePotion('p_1', 1);

    expect(session.state.workshop.queue, isEmpty);
    expect(session.state.workshop.craftedPotionStacks, isEmpty);
    expect(
      session.state.workshop.logs.first,
      'Cannot enqueue p_1 x1 / materials missing',
    );
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
      expect(lockedPotion.lockReason, '특수 재료 m_30 드롭 필요');
    },
  );

  test('resumeBlocked requeues blocked job when materials are replenished', () {
    final SessionController session = buildSession();
    final WorkshopCraftQueueController controller = buildController(
      session,
      craftingSeed: 5,
    );

    session.state = session.state.copyWith(
      workshop: session.state.workshop.copyWith(
        queue: <CraftQueueJob>[
          const CraftQueueJob(
            id: 'job_retry',
            potionId: 'p_1',
            repeatCount: 1,
            retryPolicy: CraftRetryPolicy(maxRetries: 2),
            status: QueueJobStatus.blocked,
            eta: Duration.zero,
          ),
        ],
      ),
    );

    controller.resumeBlocked('job_retry');

    expect(session.state.workshop.queue.single.status, QueueJobStatus.blocked);
    expect(
      session.state.workshop.logs.first,
      'Cannot resume job_retry / materials missing',
    );

    session.state = session.state.copyWith(
      workshop: session.state.workshop.copyWith(
        extractedTraitInventory: const <String, double>{
          't_hp': 0.6,
          't_atk': 0.4,
        },
      ),
    );

    controller.resumeBlocked('job_retry');

    expect(session.state.workshop.queue.single.status, QueueJobStatus.queued);
    expect(
      session.state.workshop.queue.single.eta,
      const Duration(seconds: 15),
    );
    expect(session.state.workshop.logs.first, 'Resumed craft job job_retry');
  });

  test('clearCompleted removes completed jobs from queue', () {
    final SessionController session = buildSession();
    final WorkshopCraftQueueController controller = buildController(session);

    session.state = session.state.copyWith(
      workshop: session.state.workshop.copyWith(
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
            id: 'job_wait',
            potionId: 'p_2',
            repeatCount: 1,
            retryPolicy: CraftRetryPolicy(maxRetries: 2),
            status: QueueJobStatus.queued,
            eta: Duration(seconds: 15),
          ),
        ],
      ),
    );

    controller.clearCompleted();

    expect(session.state.workshop.queue, hasLength(1));
    expect(session.state.workshop.queue.single.id, 'job_wait');
    expect(session.state.workshop.logs.first, 'Cleared completed craft jobs');
  });
}
