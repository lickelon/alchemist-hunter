import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alchemist_hunter/core/session/session_providers.dart';
import 'package:alchemist_hunter/features/workshop/domain/services/potion_crafting_service.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';
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

class EnqueueQuantityView {
  const EnqueueQuantityView({
    required this.quantity,
    required this.label,
    required this.requirementText,
  });

  final int quantity;
  final String label;
  final String requirementText;
}

class CraftQueueJobView {
  const CraftQueueJobView({
    required this.id,
    required this.title,
    required this.statusText,
    required this.canResume,
    required this.isCompleted,
  });

  final String id;
  final String title;
  final String statusText;
  final bool canResume;
  final bool isCompleted;
}

final Provider<List<CraftQueueJob>> craftQueueProvider =
    Provider<List<CraftQueueJob>>((Ref ref) {
      return ref.watch(
        sessionControllerProvider.select(
          (SessionState state) => state.workshop.queue,
        ),
      );
    });

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

final workshopEnqueueQuantityViewsProvider =
    Provider.family<List<EnqueueQuantityView>, String>((
      Ref ref,
      String potionId,
    ) {
      final PotionBlueprint blueprint = ref
          .watch(potionsProvider)
          .firstWhere((PotionBlueprint potion) => potion.id == potionId);
      final PotionCraftingService craftingService = ref.watch(
        potionCraftingServiceProvider,
      );
      final PotionQueueOptionView option = ref
          .watch(workshopPotionQueueOptionViewsProvider)
          .firstWhere(
            (PotionQueueOptionView entry) => entry.potionId == potionId,
          );
      final List<int> quantities = <int>{
        if (option.maxCraftableCount >= 1) 1,
        if (option.maxCraftableCount >= 3) 3,
        if (option.maxCraftableCount >= 5) 5,
        option.maxCraftableCount,
      }.toList()..sort();
      final List<TraitUnit> traits = ref.watch(traitsProvider);
      final Map<String, String> traitNames = <String, String>{
        for (final TraitUnit trait in traits) trait.id: trait.name,
      };
      return quantities.map((int quantity) {
        final Map<String, double>? requirements = craftingService
            .requiredTraitsForRepeatCount(
              blueprint: blueprint,
              repeatCount: quantity,
            );
        return EnqueueQuantityView(
          quantity: quantity,
          label: quantity == option.maxCraftableCount
              ? '최대 등록'
              : '$quantity회 등록',
          requirementText: _formatTraitRequirements(requirements, traitNames),
        );
      }).toList();
    });

final Provider<List<CraftQueueJobView>> craftQueueJobViewsProvider =
    Provider<List<CraftQueueJobView>>((Ref ref) {
      final List<CraftQueueJob> queue = ref.watch(craftQueueProvider);
      final List<PotionBlueprint> catalog = ref.watch(potionsProvider);
      final PotionCraftingService craftingService = ref.watch(
        potionCraftingServiceProvider,
      );
      final Map<String, double> extractedInventory = ref.watch(
        sessionControllerProvider.select(
          (SessionState state) => state.workshop.extractedTraitInventory,
        ),
      );
      final List<TraitUnit> traits = ref.watch(traitsProvider);
      final Map<String, String> traitNames = <String, String>{
        for (final TraitUnit trait in traits) trait.id: trait.name,
      };
      final List<CraftQueueJob> sortedQueue = <CraftQueueJob>[...queue]
        ..sort((CraftQueueJob left, CraftQueueJob right) {
          final int leftRank = _statusRank(left.status);
          final int rightRank = _statusRank(right.status);
          if (leftRank != rightRank) {
            return leftRank.compareTo(rightRank);
          }
          return left.id.compareTo(right.id);
        });
      return sortedQueue.take(20).map((CraftQueueJob job) {
        final PotionBlueprint blueprint = catalog.firstWhere(
          (PotionBlueprint potion) => potion.id == job.potionId,
          orElse: () => PotionBlueprint(
            id: job.potionId,
            name: job.potionId,
            targetTraits: const <String, double>{},
            baseValue: 0,
            useType: PotionUseType.sell,
          ),
        );
        final int remainingCount = job.repeatCount - job.currentRepeat;
        final Map<String, double>? requirements = remainingCount > 0
            ? craftingService.requiredTraitsForRepeatCount(
                blueprint: blueprint,
                repeatCount: remainingCount,
              )
            : null;
        final bool canResume =
            job.status == QueueJobStatus.blocked &&
            remainingCount > 0 &&
            craftingService.canCraftRepeatCount(
              blueprint: blueprint,
              extractedInventory: extractedInventory,
              repeatCount: remainingCount,
            );
        return CraftQueueJobView(
          id: job.id,
          title: '${blueprint.name} ${job.currentRepeat}/${job.repeatCount}',
          statusText: _queueStatusText(
            job: job,
            canResume: canResume,
            lackingTraits: _formatMissingTraits(
              requirements: requirements,
              extractedInventory: extractedInventory,
              traitNames: traitNames,
            ),
          ),
          canResume: canResume,
          isCompleted: job.status == QueueJobStatus.completed,
        );
      }).toList();
    });

int _statusRank(QueueJobStatus status) {
  return switch (status) {
    QueueJobStatus.processing => 0,
    QueueJobStatus.blocked => 1,
    QueueJobStatus.queued => 2,
    QueueJobStatus.completed => 3,
  };
}

String _formatTraitRequirements(
  Map<String, double>? requirements,
  Map<String, String> traitNames,
) {
  if (requirements == null || requirements.isEmpty) {
    return '필요 특성 계산 불가';
  }
  return requirements.entries
      .map(
        (MapEntry<String, double> entry) =>
            '${traitNames[entry.key] ?? entry.key} ${entry.value.toStringAsFixed(2)}',
      )
      .join(', ');
}

String _queueStatusText({
  required CraftQueueJob job,
  required bool canResume,
  required String? lackingTraits,
}) {
  if (job.status == QueueJobStatus.blocked) {
    if (canResume) {
      return '상태 진행 불가, 추출 특성 보충 후 재개 가능';
    }
    if (lackingTraits != null && lackingTraits.isNotEmpty) {
      return '상태 진행 불가, 부족 특성: $lackingTraits';
    }
    return '상태 진행 불가, 추출 특성 부족';
  }
  if (job.status == QueueJobStatus.completed) {
    return '상태 완료';
  }
  if (job.status == QueueJobStatus.processing) {
    return '상태 진행 중, ETA ${job.eta.inSeconds}s';
  }
  return '상태 대기 중, ${job.currentRepeat}/${job.repeatCount}';
}

String? _formatMissingTraits({
  required Map<String, double>? requirements,
  required Map<String, double> extractedInventory,
  required Map<String, String> traitNames,
}) {
  if (requirements == null || requirements.isEmpty) {
    return null;
  }
  final List<String> missing = <String>[];
  for (final MapEntry<String, double> entry in requirements.entries) {
    final double owned = extractedInventory[entry.key] ?? 0;
    if (owned + 0.0001 >= entry.value) {
      continue;
    }
    missing.add(
      '${traitNames[entry.key] ?? entry.key} ${(entry.value - owned).toStringAsFixed(2)}',
    );
  }
  if (missing.isEmpty) {
    return null;
  }
  return missing.join(', ');
}
