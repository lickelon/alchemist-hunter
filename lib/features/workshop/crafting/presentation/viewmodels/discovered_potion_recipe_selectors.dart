import 'package:alchemist_hunter/app/catalog/app_catalog_providers.dart';
import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/shared/presentation/viewmodels/workshop_resource_selectors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DiscoveredPotionRecipeView {
  const DiscoveredPotionRecipeView({
    required this.potionId,
    required this.title,
    required this.qualityLabel,
    required this.ratioBadgeLabels,
    required this.traits,
    required this.maxCraftableCount,
    required this.craftableNow,
    required this.queueFull,
  });

  final String potionId;
  final String title;
  final String qualityLabel;
  final List<String> ratioBadgeLabels;
  final Map<String, double> traits;
  final int maxCraftableCount;
  final bool craftableNow;
  final bool queueFull;
}

final Provider<List<DiscoveredPotionRecipeView>>
workshopDiscoveredPotionRecipeViewsProvider =
    Provider<List<DiscoveredPotionRecipeView>>((Ref ref) {
      final SessionState state = ref.watch(sessionControllerProvider);
      final List<PotionBlueprint> potions = ref.watch(potionsProvider);
      final List<TraitUnit> traits = ref.watch(traitsProvider);
      final int queueCapacity = ref.watch(workshopQueueCapacityProvider);
      final bool queueFull = state.workshop.queue.length >= queueCapacity;
      final Map<String, PotionBlueprint> potionMap = <String, PotionBlueprint>{
        for (final PotionBlueprint potion in potions) potion.id: potion,
      };
      final Map<String, String> traitNames = <String, String>{
        for (final TraitUnit trait in traits) trait.id: trait.name,
      };

      final List<DiscoveredPotionRecipeView> views = state
          .workshop
          .discoveredPotionRecipes
          .values
          .map((DiscoveredPotionRecipe recipe) {
            final int maxCraftableCount = _traitRecipeMaxCraftableCount(
              requiredTraits: recipe.discoveredTraits,
              extractedInventory: state.workshop.extractedTraitInventory,
            );
            return DiscoveredPotionRecipeView(
              potionId: recipe.potionId,
              title: potionMap[recipe.potionId]?.name ?? recipe.potionId,
              qualityLabel: recipe.bestKnownGrade.name.toUpperCase(),
              ratioBadgeLabels: _traitRatioBadgeLabels(
                recipe.discoveredTraits,
                traitNames: traitNames,
              ),
              traits: recipe.discoveredTraits,
              maxCraftableCount: maxCraftableCount,
              craftableNow: maxCraftableCount > 0 && !queueFull,
              queueFull: queueFull,
            );
          })
          .toList(growable: false);
      views.sort(
        (DiscoveredPotionRecipeView left, DiscoveredPotionRecipeView right) =>
            left.potionId.compareTo(right.potionId),
      );
      return views;
    });

int _traitRecipeMaxCraftableCount({
  required Map<String, double> requiredTraits,
  required Map<String, double> extractedInventory,
}) {
  if (requiredTraits.isEmpty) {
    return 0;
  }
  final List<int> counts = requiredTraits.entries
      .where((MapEntry<String, double> entry) => entry.value > 0)
      .map(
        (MapEntry<String, double> entry) =>
            ((extractedInventory[entry.key] ?? 0) / entry.value).floor(),
      )
      .toList();
  if (counts.isEmpty) {
    return 0;
  }
  return counts.reduce(_minInt);
}

int _minInt(int left, int right) {
  return left < right ? left : right;
}

List<String> _traitRatioBadgeLabels(
  Map<String, double> requiredTraits, {
  required Map<String, String> traitNames,
}) {
  final List<MapEntry<String, double>> entries = requiredTraits.entries
      .where((MapEntry<String, double> entry) => entry.value > 0)
      .toList(growable: false);
  if (entries.isEmpty) {
    return <String>[];
  }
  return entries
      .map(
        (MapEntry<String, double> entry) =>
            '${traitNames[entry.key] ?? entry.key} ${_ratioPercent(entry.value)}',
      )
      .toList(growable: false);
}

String _ratioPercent(double value) {
  return '${(value * 100).round()}';
}
