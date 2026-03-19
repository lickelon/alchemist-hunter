import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/domain/services/potion_crafting_service.dart';
import 'package:alchemist_hunter/features/workshop/presentation/viewmodels/workshop_shared_selectors.dart';
import 'package:alchemist_hunter/features/workshop/presentation/viewmodels/workshop_service_providers.dart';
import 'package:alchemist_hunter/features/workshop/workshop_catalog.dart';

class PotionQueueOptionView {
  const PotionQueueOptionView({
    required this.potionId,
    required this.title,
    required this.unlocked,
    required this.lockReason,
    required this.craftableNow,
    required this.maxCraftableCount,
    required this.materialHint,
    required this.queueFull,
  });

  final String potionId;
  final String title;
  final bool unlocked;
  final String lockReason;
  final bool craftableNow;
  final int maxCraftableCount;
  final String materialHint;
  final bool queueFull;
}

class WorkshopCraftMenuSummaryView {
  const WorkshopCraftMenuSummaryView({
    required this.craftableCount,
    required this.unlockedCount,
    required this.description,
  });

  final int craftableCount;
  final int unlockedCount;
  final String description;
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
  final int queueLength = ref.watch(
    sessionControllerProvider.select(
      (SessionState state) => state.workshop.queue.length,
    ),
  );
  final int queueCapacity = ref.watch(workshopQueueCapacityProvider);
  final PotionCraftingService craftingService = ref.watch(
    potionCraftingServiceProvider,
  );
  final bool queueFull = queueLength >= queueCapacity;

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

  final List<PotionQueueOptionView> views = catalog.map((
    PotionBlueprint potion,
  ) {
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
      materialHint: !unlocked
          ? lockReason(potion)
          : queueFull
          ? '큐 가득 참 ($queueLength/$queueCapacity)'
          : (craftableNow ? '최대 $maxCraftableCount회 제작 가능' : '추출 특성 부족'),
      queueFull: queueFull,
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

final Provider<WorkshopCraftMenuSummaryView> workshopCraftMenuSummaryProvider =
    Provider<WorkshopCraftMenuSummaryView>((Ref ref) {
      final List<PotionQueueOptionView> options = ref.watch(
        workshopPotionQueueOptionViewsProvider,
      );
      final int unlockedCount = options.where((entry) => entry.unlocked).length;
      final int craftableCount = options.where((entry) => entry.craftableNow).length;
      final String description = unlockedCount == 0
          ? '제조 가능한 포션 없음'
          : '즉시 제작 가능 $craftableCount종 / 해금 포션 $unlockedCount종';
      return WorkshopCraftMenuSummaryView(
        craftableCount: craftableCount,
        unlockedCount: unlockedCount,
        description: description,
      );
    });
