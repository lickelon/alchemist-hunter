import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/workshop/crafting/domain/services/potion_display_service.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:alchemist_hunter/app/catalog/app_catalog_providers.dart';

class CraftedPotionStackView {
  const CraftedPotionStackView({
    required this.stackKey,
    required this.name,
    required this.quantity,
    required this.qualityLabel,
    required this.scoreLabel,
    required this.traitsLabel,
  });

  final String stackKey;
  final String name;
  final int quantity;
  final String qualityLabel;
  final String scoreLabel;
  final String traitsLabel;
}

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

final Provider<List<CraftedPotionStackView>> craftedPotionStackViewsProvider =
    Provider<List<CraftedPotionStackView>>((Ref ref) {
      final Map<String, int> stacks = ref.watch(craftedPotionStacksProvider);
      final Map<String, CraftedPotion> details = ref.watch(
        craftedPotionDetailsProvider,
      );
      final potionCatalogRepository = ref.watch(
        potionCatalogRepositoryProvider,
      );
      final materialCatalogRepository = ref.watch(
        materialCatalogRepositoryProvider,
      );
      const PotionDisplayService displayService = PotionDisplayService();
      final List<CraftedPotionStackView> views = stacks.entries.map((
        MapEntry<String, int> entry,
      ) {
        final CraftedPotion? detail = details[entry.key];
        return CraftedPotionStackView(
          stackKey: entry.key,
          name: displayService.potionName(
            stackKey: entry.key,
            detail: detail,
            potionCatalogRepository: potionCatalogRepository,
          ),
          quantity: entry.value,
          qualityLabel: detail?.qualityGrade.name.toUpperCase() ?? '-',
          scoreLabel: (detail?.qualityScore ?? 0).toStringAsFixed(2),
          traitsLabel: displayService.traitsLabel(
            detail: detail,
            materialCatalogRepository: materialCatalogRepository,
          ),
        );
      }).toList();
      views.sort((CraftedPotionStackView left, CraftedPotionStackView right) {
        final int nameCompare = left.name.compareTo(right.name);
        if (nameCompare != 0) {
          return nameCompare;
        }
        return left.stackKey.compareTo(right.stackKey);
      });
      return views;
    });
