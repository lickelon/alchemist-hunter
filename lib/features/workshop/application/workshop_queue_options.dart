import 'package:alchemist_hunter/features/session/application/session_providers.dart';
import 'package:alchemist_hunter/features/workshop/application/workshop_controller.dart';
import 'package:alchemist_hunter/features/workshop/application/services/potion_crafting_service.dart';
import 'package:alchemist_hunter/features/workshop/application/workshop_selectors.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
      final List<PotionBlueprint> catalog = ref.watch(
        workshopPotionCatalogProvider,
      );
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
      final List<MaterialEntity> materials = ref.watch(materialsProvider);

      bool isUnlocked(PotionBlueprint potion) {
        final int index = catalog.indexWhere(
          (PotionBlueprint p) => p.id == potion.id,
        );
        if (index < 10) {
          return true;
        }
        if (index < 13) {
          return unlockFlags.contains('potion_special_1');
        }
        return unlockFlags.contains('potion_special_2');
      }

      String lockReason(PotionBlueprint potion) {
        final int index = catalog.indexWhere(
          (PotionBlueprint p) => p.id == potion.id,
        );
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
          materials: materials,
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
      }).toList()..sort((PotionQueueOption left, PotionQueueOption right) {
        if (left.unlocked == right.unlocked) {
          return potionOrder(
            left.blueprint.id,
          ).compareTo(potionOrder(right.blueprint.id));
        }
        return left.unlocked ? -1 : 1;
      });
    });
