import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/presentation/viewmodels/workshop_catalog_providers.dart';

class EnchantPotionView {
  const EnchantPotionView({
    required this.stackKey,
    required this.name,
    required this.quantity,
    required this.qualityLabel,
    required this.traitsLabel,
  });

  final String stackKey;
  final String name;
  final int quantity;
  final String qualityLabel;
  final String traitsLabel;
}

final Provider<List<EnchantPotionView>>
enchantPotionViewsProvider = Provider<List<EnchantPotionView>>((Ref ref) {
  final Map<String, int> stacks = ref.watch(
    sessionControllerProvider.select(
      (SessionState state) => state.workshop.craftedPotionStacks,
    ),
  );
  final Map<String, CraftedPotion> details = ref.watch(
    sessionControllerProvider.select(
      (SessionState state) => state.workshop.craftedPotionDetails,
    ),
  );
  final potionCatalogRepository = ref.watch(potionCatalogRepositoryProvider);
  final materialCatalogRepository = ref.watch(materialCatalogRepositoryProvider);

  final List<EnchantPotionView> views = stacks.entries.map((MapEntry<String, int> entry) {
    final CraftedPotion? detail = details[entry.key];
    final PotionBlueprint? potion = detail == null
        ? null
        : potionCatalogRepository.findPotionById(detail.typePotionId);
    final List<MapEntry<String, double>> sortedTraits =
        detail?.traits.entries.toList() ?? <MapEntry<String, double>>[];
    sortedTraits.sort(
      (MapEntry<String, double> left, MapEntry<String, double> right) =>
          right.value.compareTo(left.value),
    );
    final String traitsLabel = sortedTraits
        .take(2)
        .map((MapEntry<String, double> trait) {
          final TraitUnit? unit = materialCatalogRepository.findTraitById(
            trait.key,
          );
          return '${unit?.name ?? trait.key} ${(trait.value * 100).round()}%';
        })
        .join(', ');

    return EnchantPotionView(
      stackKey: entry.key,
      name: potion?.name ?? entry.key,
      quantity: entry.value,
      qualityLabel: detail?.qualityGrade.name.toUpperCase() ?? '-',
      traitsLabel: traitsLabel.isEmpty ? '특성 정보 없음' : traitsLabel,
    );
  }).toList();

  views.sort((EnchantPotionView left, EnchantPotionView right) {
    final int quantityCompare = right.quantity.compareTo(left.quantity);
    if (quantityCompare != 0) {
      return quantityCompare;
    }
    return left.name.compareTo(right.name);
  });
  return views;
});
