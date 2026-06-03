import 'package:alchemist_hunter/features/workshop/crafting/domain/repositories/potion_catalog_repository.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/extraction/domain/repositories/material_catalog_repository.dart';

String potionNameLabel({
  required String stackKey,
  required CraftedPotion? detail,
  required PotionCatalogRepository potionCatalogRepository,
}) {
  final String potionId = detail?.typePotionId ?? _stackPotionId(stackKey);
  return potionCatalogRepository.findPotionById(potionId)?.name ?? stackKey;
}

String potionTraitsLabel({
  required CraftedPotion? detail,
  required MaterialCatalogRepository materialCatalogRepository,
  int? maxEntries,
}) {
  final List<MapEntry<String, double>> entries =
      detail?.traits.entries.toList() ?? <MapEntry<String, double>>[];
  if (entries.isEmpty) {
    return '원소 정보 없음';
  }
  entries.sort((MapEntry<String, double> left, MapEntry<String, double> right) {
    final int valueCompare = right.value.compareTo(left.value);
    if (valueCompare != 0) {
      return valueCompare;
    }
    return left.key.compareTo(right.key);
  });
  final Iterable<MapEntry<String, double>> visibleEntries = maxEntries == null
      ? entries
      : entries.take(maxEntries);
  return visibleEntries
      .map((MapEntry<String, double> trait) {
        final TraitUnit? unit = materialCatalogRepository.findTraitById(
          trait.key,
        );
        return '${unit?.name ?? trait.key} ${_percentLabel(trait.value)}';
      })
      .join(', ');
}

String _percentLabel(double value) {
  final double percent = value * 100;
  final double rounded = double.parse(percent.toStringAsFixed(1));
  if ((rounded - rounded.round()).abs() < 0.001) {
    return '${rounded.round()}%';
  }
  return '${rounded.toStringAsFixed(1)}%';
}

String _stackPotionId(String stackKey) {
  final List<String> parts = stackKey.split('|');
  if (parts.isEmpty || parts.first.isEmpty) {
    return stackKey;
  }
  return parts.first;
}
