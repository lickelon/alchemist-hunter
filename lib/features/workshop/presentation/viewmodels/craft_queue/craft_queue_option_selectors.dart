import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/domain/services/potion_crafting_service.dart';
import 'package:alchemist_hunter/features/workshop/presentation/viewmodels/workshop_catalog_providers.dart';
import 'package:alchemist_hunter/features/workshop/presentation/viewmodels/workshop_service_providers.dart';

class PotionQueueOptionView {
  const PotionQueueOptionView({
    required this.potionId,
    required this.title,
    required this.unlocked,
    required this.lockReason,
    required this.craftableNow,
    required this.maxCraftableCount,
    required this.materialHint,
  });

  final String potionId;
  final String title;
  final bool unlocked;
  final String lockReason;
  final bool craftableNow;
  final int maxCraftableCount;
  final String materialHint;
}

final Provider<List<PotionQueueOptionView>>
workshopPotionQueueOptionViewsProvider = Provider<List<PotionQueueOptionView>>((
  Ref ref,
) {
  final List<PotionBlueprint> catalog = ref.watch(potionsProvider);
  final Set<String> unlockFlags = ref.watch(
    sessionControllerProvider.select(
      (SessionState state) => state.battle.progress.unlockFlags,
    ),
  );
  final Map<String, double> extractedInventory = ref.watch(
    sessionControllerProvider.select(
      (SessionState state) => state.workshop.extractedTraitInventory,
    ),
  );
  final PotionCraftingService craftingService = ref.watch(
    potionCraftingServiceProvider,
  );

  bool isUnlocked(PotionBlueprint potion) {
    final int index = catalog.indexWhere(
      (PotionBlueprint entry) => entry.id == potion.id,
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
      (PotionBlueprint entry) => entry.id == potion.id,
    );
    if (index < 10) {
      return '';
    }
    if (index < 13) {
      return '특수 재료 Starfire Pollen 드롭 필요';
    }
    return '특수 재료 Moontear Crystal 드롭 필요';
  }

  int potionOrder(String id) {
    final String numericSuffix = id.split('_').last;
    return int.tryParse(numericSuffix) ?? 999999;
  }

  final List<PotionQueueOptionView> views = catalog.map((PotionBlueprint potion) {
    final bool unlocked = isUnlocked(potion);
    final int maxCraftableCount = craftingService.maxCraftableRepeatCount(
      blueprint: potion,
      extractedInventory: extractedInventory,
    );
    final bool craftableNow = maxCraftableCount > 0;
    return PotionQueueOptionView(
      potionId: potion.id,
      title: potion.name,
      unlocked: unlocked,
      lockReason: unlocked ? '' : lockReason(potion),
      craftableNow: unlocked && craftableNow,
      maxCraftableCount: unlocked ? maxCraftableCount : 0,
      materialHint: unlocked
          ? (craftableNow ? '최대 $maxCraftableCount회 제작 가능' : '추출 특성 부족')
          : lockReason(potion),
    );
  }).toList();

  views.sort((PotionQueueOptionView left, PotionQueueOptionView right) {
    if (left.unlocked == right.unlocked) {
      return potionOrder(left.potionId).compareTo(potionOrder(right.potionId));
    }
    return left.unlocked ? -1 : 1;
  });
  return views;
});
