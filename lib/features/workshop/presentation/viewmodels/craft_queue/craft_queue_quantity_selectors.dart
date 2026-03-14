import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/domain/services/potion_crafting_service.dart';
import 'package:alchemist_hunter/features/workshop/presentation/viewmodels/craft_queue/craft_queue_labels.dart';
import 'package:alchemist_hunter/features/workshop/presentation/viewmodels/craft_queue/craft_queue_option_selectors.dart';
import 'package:alchemist_hunter/features/workshop/presentation/viewmodels/workshop_catalog_providers.dart';
import 'package:alchemist_hunter/features/workshop/presentation/viewmodels/workshop_service_providers.dart';

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
          label: quantity == option.maxCraftableCount ? '최대 등록' : '$quantity회 등록',
          requirementText: formatTraitRequirements(requirements, traitNames),
        );
      }).toList();
    });
