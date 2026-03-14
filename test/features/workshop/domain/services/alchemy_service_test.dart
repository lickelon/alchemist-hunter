import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/domain/services/alchemy_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final AlchemyService service = AlchemyService();

  test('compound decomposition returns single traits', () {
    const MaterialEntity material = MaterialEntity(
      id: 'm1',
      name: 'Test',
      rarity: MaterialRarity.common,
      analyzable: true,
      source: 'test',
      traits: <TraitUnit>[
        TraitUnit(
          id: 'c1',
          name: 'Combo',
          type: TraitType.compound,
          potency: 2,
          components: <String, double>{'a': 0.5, 'b': 0.5},
        ),
      ],
    );

    final List<TraitUnit> result = service.decomposeCompound(material, 'c1');
    expect(result.length, 2);
    expect(result.first.type, TraitType.single);
  });

  test('synthesize creates compound trait', () {
    final TraitUnit result = service.synthesizeCompound(
      id: 'c2',
      name: 'Synth',
      inputTraits: const <TraitUnit>[
        TraitUnit(id: 'a', name: 'A', type: TraitType.single, potency: 1),
        TraitUnit(id: 'b', name: 'B', type: TraitType.single, potency: 3),
      ],
    );

    expect(result.type, TraitType.compound);
    expect(result.potency, 4);
    expect(result.components['b'], 0.75);
  });

  test('extractTraitInventory flattens compound traits into single traits', () {
    const MaterialEntity material = MaterialEntity(
      id: 'm2',
      name: 'Test 2',
      rarity: MaterialRarity.common,
      analyzable: true,
      source: 'test',
      traits: <TraitUnit>[
        TraitUnit(
          id: 'c1',
          name: 'Combo',
          type: TraitType.compound,
          potency: 2,
          components: <String, double>{'a': 0.5, 'b': 0.5},
        ),
      ],
    );

    const ExtractionProfile profile = ExtractionProfile(
      id: 'full',
      mode: ExtractionMode.full,
      yieldRate: 0.5,
      purityRate: 1,
      timeCost: Duration.zero,
    );

    final Map<String, double> extracted = service.extractTraitInventory(
      material: material,
      profile: profile,
    );

    expect(extracted['a'], 0.5);
    expect(extracted['b'], 0.5);
  });
}
