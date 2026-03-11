import 'package:alchemist_hunter/features/session/application/session_providers.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MaterialInventoryView {
  const MaterialInventoryView({
    required this.id,
    required this.name,
    required this.rarity,
    required this.quantity,
    required this.traitSummary,
  });

  final String id;
  final String name;
  final MaterialRarity rarity;
  final int quantity;
  final String traitSummary;
}

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

final Provider<List<MaterialInventoryView>> materialInventoryViewsProvider =
    Provider<List<MaterialInventoryView>>((Ref ref) {
      final List<MaterialEntity> materials = ref.watch(materialsProvider);
      final List<MapEntry<String, int>> inventory = ref.watch(
        sortedMaterialInventoryProvider,
      );
      final Map<String, MaterialEntity> materialMap = <String, MaterialEntity>{
        for (final MaterialEntity material in materials) material.id: material,
      };

      return inventory.map((MapEntry<String, int> entry) {
        final MaterialEntity? material = materialMap[entry.key];
        final String traitSummary = material == null
            ? '특성 정보 없음'
            : material.traits.map((TraitUnit trait) => trait.name).join(' / ');
        return MaterialInventoryView(
          id: entry.key,
          name: material?.name ?? entry.key,
          rarity: material?.rarity ?? MaterialRarity.common,
          quantity: entry.value,
          traitSummary: traitSummary,
        );
      }).toList();
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
