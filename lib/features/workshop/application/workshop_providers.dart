import 'dart:math';

import 'package:alchemist_hunter/features/session/application/session_logic.dart';
import 'package:alchemist_hunter/features/session/application/session_providers.dart';
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
