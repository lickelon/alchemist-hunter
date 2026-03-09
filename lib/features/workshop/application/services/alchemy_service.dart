import 'package:alchemist_hunter/features/workshop/domain/models.dart';

class AlchemyService {
  List<TraitUnit> analyzeMaterial(MaterialEntity material) {
    if (!material.analyzable) {
      return const <TraitUnit>[];
    }
    return material.traits;
  }

  List<TraitUnit> decomposeCompound(
    MaterialEntity material,
    String traitId,
  ) {
    final TraitUnit trait = material.traits.firstWhere(
      (TraitUnit t) => t.id == traitId,
      orElse: () => throw ArgumentError('Trait not found: $traitId'),
    );

    if (trait.type != TraitType.compound || trait.components.isEmpty) {
      throw ArgumentError('Trait is not decomposable: $traitId');
    }

    return trait.components.entries
        .map(
          (MapEntry<String, double> entry) => TraitUnit(
            id: entry.key,
            name: entry.key,
            type: TraitType.single,
            potency: trait.potency * entry.value,
          ),
        )
        .toList();
  }

  TraitUnit synthesizeCompound({
    required String id,
    required String name,
    required List<TraitUnit> inputTraits,
  }) {
    if (inputTraits.isEmpty) {
      throw ArgumentError('inputTraits cannot be empty');
    }

    double total = 0;
    final Map<String, double> components = <String, double>{};
    for (final TraitUnit trait in inputTraits) {
      total += trait.potency;
      components[trait.id] = (components[trait.id] ?? 0) + trait.potency;
    }

    final Map<String, double> normalized = components.map(
      (String key, double value) => MapEntry<String, double>(key, value / total),
    );

    return TraitUnit(
      id: id,
      name: name,
      type: TraitType.compound,
      potency: total,
      components: normalized,
    );
  }

  List<ExtractedTrait> extractTraits({
    required MaterialEntity material,
    required ExtractionProfile profile,
    List<String>? selectedTraits,
  }) {
    List<TraitUnit> sourceTraits = material.traits;
    if (profile.mode == ExtractionMode.selective && selectedTraits != null) {
      sourceTraits = sourceTraits
          .where((TraitUnit t) => selectedTraits.contains(t.id))
          .toList();
    }

    return sourceTraits
        .map(
          (TraitUnit trait) => ExtractedTrait(
            traitId: trait.id,
            name: trait.name,
            amount: trait.potency * profile.yieldRate,
            purity: profile.purityRate,
          ),
        )
        .toList();
  }
}
