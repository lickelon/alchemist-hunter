import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/domain/services/potion_crafting_service.dart';
import 'package:alchemist_hunter/features/workshop/presentation/viewmodels/craft_queue/craft_queue_labels.dart';
import 'package:alchemist_hunter/features/workshop/presentation/viewmodels/workshop_catalog_providers.dart';
import 'package:alchemist_hunter/features/workshop/presentation/viewmodels/workshop_service_providers.dart';

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
          final int leftRank = statusRank(left.status);
          final int rightRank = statusRank(right.status);
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
          statusText: queueStatusText(
            job: job,
            canResume: canResume,
            lackingTraits: formatMissingTraits(
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
