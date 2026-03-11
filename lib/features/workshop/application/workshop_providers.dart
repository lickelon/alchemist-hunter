import 'dart:math';

import 'package:alchemist_hunter/features/session/application/session_providers.dart';
import 'package:alchemist_hunter/features/session/application/session_logic.dart';
import 'package:alchemist_hunter/features/workshop/application/services/craft_queue_service.dart';
import 'package:alchemist_hunter/features/workshop/application/services/potion_crafting_service.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final Provider<CraftQueueService> craftQueueServiceProvider =
    Provider<CraftQueueService>(
      (Ref ref) => CraftQueueService(random: Random(7)),
    );

final Provider<PotionCraftingService> potionCraftingServiceProvider =
    Provider<PotionCraftingService>(
      (Ref ref) => PotionCraftingService(random: Random(13)),
    );

class WorkshopController {
  WorkshopController(
    this._session,
    this._queueService,
    this._craftingService, {
    WorkshopDomain workshopDomain = const WorkshopDomain(),
  }) : _workshopDomain = workshopDomain;

  final SessionController _session;
  final CraftQueueService _queueService;
  final PotionCraftingService _craftingService;
  final WorkshopDomain _workshopDomain;

  void enqueuePotion(String potionId, int repeatCount) {
    _session.applyMutation(
      _workshopDomain.enqueuePotion(
        state: _session.snapshot(),
        potionId: potionId,
        repeatCount: repeatCount,
        now: _session.now(),
        queueService: _queueService,
        craftingService: _craftingService,
      ),
    );
  }

  void tickCraftQueue() {
    _session.applyMutation(
      _workshopDomain.tickCraftQueue(
        state: _session.snapshot(),
        queueService: _queueService,
        craftingService: _craftingService,
      ),
    );
  }
}

final Provider<WorkshopController> workshopControllerProvider =
    Provider<WorkshopController>((Ref ref) {
      return WorkshopController(
        ref.read(sessionControllerProvider.notifier),
        ref.read(craftQueueServiceProvider),
        ref.read(potionCraftingServiceProvider),
      );
    });

final Provider<int> workshopEssenceProvider = Provider<int>((Ref ref) {
  return ref.watch(
    sessionControllerProvider.select((SessionState state) => state.player.essence),
  );
});

final Provider<List<CraftQueueJob>> craftQueueProvider =
    Provider<List<CraftQueueJob>>((Ref ref) {
      return ref.watch(
        sessionControllerProvider.select((SessionState state) => state.workshop.queue),
      );
    });

final Provider<List<MapEntry<String, int>>> sortedMaterialInventoryProvider =
    Provider<List<MapEntry<String, int>>>((Ref ref) {
      final Map<String, int> inventory = ref.watch(
        sessionControllerProvider.select(
          (SessionState state) => state.player.materialInventory,
        ),
      );
      final List<MapEntry<String, int>> entries = inventory.entries.toList();
      entries.sort((MapEntry<String, int> left, MapEntry<String, int> right) {
        return right.value.compareTo(left.value);
      });
      return entries;
    });

final Provider<Map<String, int>> craftedPotionStacksProvider =
    Provider<Map<String, int>>((Ref ref) {
      return ref.watch(
        sessionControllerProvider.select(
          (SessionState state) => state.workshop.craftedPotionStacks,
        ),
      );
    });

final Provider<Map<String, CraftedPotion>> craftedPotionDetailsProvider =
    Provider<Map<String, CraftedPotion>>((Ref ref) {
      return ref.watch(
        sessionControllerProvider.select(
          (SessionState state) => state.workshop.craftedPotionDetails,
        ),
      );
    });

final Provider<List<String>> recentLogsProvider = Provider<List<String>>((
  Ref ref,
) {
  return ref.watch(
    sessionControllerProvider.select((SessionState state) => state.workshop.logs),
  );
});

final Provider<List<PotionBlueprint>> workshopPotionCatalogProvider =
    Provider<List<PotionBlueprint>>((Ref ref) {
      return ref.watch(potionsProvider);
    });

class PotionQueueOption {
  const PotionQueueOption({
    required this.blueprint,
    required this.unlocked,
    required this.lockReason,
    required this.craftableNow,
    required this.maxCraftableCount,
    required this.materialHint,
  });

  final PotionBlueprint blueprint;
  final bool unlocked;
  final String lockReason;
  final bool craftableNow;
  final int maxCraftableCount;
  final String materialHint;
}

final Provider<List<PotionQueueOption>> workshopPotionQueueOptionsProvider =
    Provider<List<PotionQueueOption>>((Ref ref) {
      final List<PotionBlueprint> catalog = ref.watch(workshopPotionCatalogProvider);
      final Set<String> unlockFlags = ref.watch(
        sessionControllerProvider.select(
          (SessionState state) => state.battle.progress.unlockFlags,
        ),
      );
      final Map<String, int> inventory = ref.watch(
        sessionControllerProvider.select(
          (SessionState state) => state.player.materialInventory,
        ),
      );
      final PotionCraftingService craftingService = ref.watch(
        potionCraftingServiceProvider,
      );

      bool isUnlocked(PotionBlueprint potion) {
        final int index = catalog.indexWhere((PotionBlueprint p) => p.id == potion.id);
        if (index < 10) {
          return true;
        }
        if (index < 13) {
          return unlockFlags.contains('potion_special_1');
        }
        return unlockFlags.contains('potion_special_2');
      }

      String lockReason(PotionBlueprint potion) {
        final int index = catalog.indexWhere((PotionBlueprint p) => p.id == potion.id);
        if (index < 10) {
          return '';
        }
        if (index < 13) {
          return '특수 재료 m_27 드롭 필요';
        }
        return '특수 재료 m_30 드롭 필요';
      }

      int potionOrder(String id) {
        final String numericSuffix = id.split('_').last;
        return int.tryParse(numericSuffix) ?? 999999;
      }

      return catalog.map((PotionBlueprint potion) {
        final bool unlocked = isUnlocked(potion);
        final int maxCraftableCount = craftingService.maxCraftableRepeatCount(
          blueprint: potion,
          inventory: inventory,
          materials: ref.read(materialsProvider),
        );
        final bool craftableNow = maxCraftableCount > 0;
        return PotionQueueOption(
          blueprint: potion,
          unlocked: unlocked,
          lockReason: unlocked ? '' : lockReason(potion),
          craftableNow: unlocked && craftableNow,
          maxCraftableCount: unlocked ? maxCraftableCount : 0,
          materialHint: unlocked
              ? (craftableNow ? '최대 $maxCraftableCount회 제작 가능' : '재료 부족')
              : lockReason(potion),
        );
      }).toList()
        ..sort((PotionQueueOption left, PotionQueueOption right) {
          if (left.unlocked == right.unlocked) {
            return potionOrder(left.blueprint.id)
                .compareTo(potionOrder(right.blueprint.id));
          }
          return left.unlocked ? -1 : 1;
        });
    });
