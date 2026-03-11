import 'package:alchemist_hunter/features/session/application/session_providers.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final Provider<int> workshopEssenceProvider = Provider<int>((Ref ref) {
  return ref.watch(
    sessionControllerProvider.select(
      (SessionState state) => state.player.essence,
    ),
  );
});

final Provider<List<CraftQueueJob>> craftQueueProvider =
    Provider<List<CraftQueueJob>>((Ref ref) {
      return ref.watch(
        sessionControllerProvider.select(
          (SessionState state) => state.workshop.queue,
        ),
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
    sessionControllerProvider.select(
      (SessionState state) => state.workshop.logs,
    ),
  );
});

final Provider<List<PotionBlueprint>> workshopPotionCatalogProvider =
    Provider<List<PotionBlueprint>>((Ref ref) {
      return ref.watch(potionsProvider);
    });
