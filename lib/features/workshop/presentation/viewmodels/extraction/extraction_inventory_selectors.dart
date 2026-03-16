import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/workshop_catalog.dart';
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

class ExtractedTraitInventoryView {
  const ExtractedTraitInventoryView({
    required this.id,
    required this.name,
    required this.amount,
  });

  final String id;
  final String name;
  final double amount;
}

final Provider<Map<String, double>> extractedTraitInventoryProvider =
    Provider<Map<String, double>>((Ref ref) {
      return ref.watch(
        sessionControllerProvider.select(
          (SessionState state) => state.workshop.extractedTraitInventory,
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

final Provider<List<ExtractedTraitInventoryView>> extractedTraitViewsProvider =
    Provider<List<ExtractedTraitInventoryView>>((Ref ref) {
      final Map<String, double> inventory = ref.watch(
        extractedTraitInventoryProvider,
      );
      final List<TraitUnit> traits = ref.watch(traitsProvider);
      final Map<String, TraitUnit> traitMap = <String, TraitUnit>{
        for (final TraitUnit trait in traits) trait.id: trait,
      };
      final List<ExtractedTraitInventoryView> views = inventory.entries.map((
        MapEntry<String, double> entry,
      ) {
        final TraitUnit? trait = traitMap[entry.key];
        return ExtractedTraitInventoryView(
          id: entry.key,
          name: trait?.name ?? entry.key,
          amount: entry.value,
        );
      }).toList();
      views.sort(
        (ExtractedTraitInventoryView left, ExtractedTraitInventoryView right) =>
            right.amount.compareTo(left.amount),
      );
      return views;
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
