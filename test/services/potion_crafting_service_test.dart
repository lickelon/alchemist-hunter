import 'dart:math';

import 'package:alchemist_hunter/features/workshop/data/dummy_data.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/application/services/potion_crafting_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final PotionCraftingService service = PotionCraftingService(
    random: Random(1),
  );

  test('recipe branch changes potion type by dominant trait ratio', () {
    final PotionBlueprint blueprint = DummyData.potions.firstWhere(
      (PotionBlueprint p) => p.id == 'p_1',
    );

    final CraftedPotion hpDominant = service.craftPotion(
      requestedBlueprint: blueprint,
      extractedTraits: const <String, double>{'t_hp': 0.7, 't_atk': 0.3},
      recipeRules: DummyData.potionRecipeRules,
      branchRules: DummyData.potionRecipeBranchRules,
      qualityRule: DummyData.potionQualityRule,
    );
    final CraftedPotion atkDominant = service.craftPotion(
      requestedBlueprint: blueprint,
      extractedTraits: const <String, double>{'t_hp': 0.3, 't_atk': 0.7},
      recipeRules: DummyData.potionRecipeRules,
      branchRules: DummyData.potionRecipeBranchRules,
      qualityRule: DummyData.potionQualityRule,
    );

    expect(hpDominant.typePotionId, 'p_1');
    expect(atkDominant.typePotionId, 'p_2');
  });

  test('quality grade is calculated by target ratio score', () {
    final PotionBlueprint blueprint = DummyData.potions.firstWhere(
      (PotionBlueprint p) => p.id == 'p_1',
    );

    final CraftedPotion high = service.craftPotion(
      requestedBlueprint: blueprint,
      extractedTraits: const <String, double>{'t_hp': 0.6, 't_atk': 0.4},
      recipeRules: DummyData.potionRecipeRules,
      branchRules: DummyData.potionRecipeBranchRules,
      qualityRule: DummyData.potionQualityRule,
    );
    final CraftedPotion low = service.craftPotion(
      requestedBlueprint: blueprint,
      extractedTraits: const <String, double>{'t_hp': 0.0, 't_atk': 1.0},
      recipeRules: DummyData.potionRecipeRules,
      branchRules: DummyData.potionRecipeBranchRules,
      qualityRule: DummyData.potionQualityRule,
    );

    expect(high.qualityGrade.index <= PotionQualityGrade.a.index, true);
    expect(low.qualityGrade, PotionQualityGrade.c);
    expect(high.qualityScore > low.qualityScore, true);
  });

  test('prepareCraftFromExtractedInventory consumes matching traits', () {
    final PotionBlueprint blueprint = DummyData.potions.firstWhere(
      (PotionBlueprint p) => p.id == 'p_1',
    );

    final ({
      Map<String, double> nextExtractedInventory,
      Map<String, double> extractedTraits,
    })?
    prepared = service.prepareCraftFromExtractedInventory(
      blueprint: blueprint,
      extractedInventory: <String, double>{'t_hp': 0.7, 't_atk': 0.6},
    );

    expect(prepared, isNotNull);
    expect(prepared!.nextExtractedInventory['t_hp'], closeTo(0.1, 0.0001));
    expect(prepared.nextExtractedInventory['t_atk'], closeTo(0.2, 0.0001));
    expect(prepared.extractedTraits.containsKey('t_hp'), true);
    expect(prepared.extractedTraits.containsKey('t_atk'), true);
  });

  test('requiredTraitsForRepeatCount returns aggregated trait amounts', () {
    final PotionBlueprint blueprint = DummyData.potions.firstWhere(
      (PotionBlueprint p) => p.id == 'p_1',
    );

    final Map<String, double>? required = service.requiredTraitsForRepeatCount(
      blueprint: blueprint,
      repeatCount: 2,
    );

    expect(required, isNotNull);
    expect(required!['t_hp'], closeTo(1.2, 0.0001));
    expect(required['t_atk'], closeTo(0.8, 0.0001));
  });
}
