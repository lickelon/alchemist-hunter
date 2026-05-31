import 'dart:math';

import 'package:alchemist_hunter/features/workshop/crafting/data/catalogs/potion_catalog.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/crafting/domain/services/potion_crafting_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final PotionCraftingService service = PotionCraftingService(
    random: Random(1),
  );

  test('recipe rules resolve potion type by main and sub traits', () {
    final PotionBlueprint blueprint = potionCatalog.firstWhere(
      (PotionBlueprint p) => p.id == 'p_1',
    );

    final CraftedPotion hpDominant = service.craftPotion(
      requestedBlueprint: blueprint,
      extractedTraits: const <String, double>{'t_hp': 0.7, 't_atk': 0.3},
      recipeRules: potionRecipeCatalog,
      qualityRule: potionQualityCatalog,
    );
    final CraftedPotion atkDominant = service.craftPotion(
      requestedBlueprint: blueprint,
      extractedTraits: const <String, double>{'t_hp': 0.3, 't_atk': 0.7},
      recipeRules: potionRecipeCatalog,
      qualityRule: potionQualityCatalog,
    );

    expect(hpDominant.typePotionId, 'p_1');
    expect(atkDominant.typePotionId, 'p_2');
  });

  test('resolves potion type from input traits without selected blueprint', () {
    final String? hpDominant = service.resolvePotionTypeFromTraits(
      inputTraits: const <String, double>{'t_hp': 7, 't_atk': 3},
      recipeRules: potionRecipeCatalog,
    );
    final String? atkDominant = service.resolvePotionTypeFromTraits(
      inputTraits: const <String, double>{'t_hp': 3, 't_atk': 7},
      recipeRules: potionRecipeCatalog,
    );
    final String? p3Recipe = service.resolvePotionTypeFromTraits(
      inputTraits: const <String, double>{'t_crit': 0.55, 't_focus': 0.45},
      recipeRules: potionRecipeCatalog,
    );
    final String? unknown = service.resolvePotionTypeFromTraits(
      inputTraits: const <String, double>{'t_luck': 1},
      recipeRules: potionRecipeCatalog,
    );

    expect(hpDominant, 'p_1');
    expect(atkDominant, 'p_2');
    expect(p3Recipe, 'p_3');
    expect(unknown, isNull);
  });

  test('recipe required traits use result potion target traits', () {
    for (final PotionRecipeRule rule in potionRecipeCatalog) {
      final PotionBlueprint resultPotion = potionCatalog.firstWhere(
        (PotionBlueprint potion) => potion.id == rule.resultPotionId,
      );

      expect(rule.requiredTraits, resultPotion.targetTraits.keys.toSet());
      expect(rule.targetTraits, resultPotion.targetTraits);
    }
  });

  test('recipe rules keep unique ordered main and sub pairs', () {
    final Set<String> pairs = <String>{};
    for (final PotionRecipeRule rule in potionRecipeCatalog) {
      expect(rule.mainTraitId, isNot(rule.subTraitId));
      expect(rule.mainPercent, greaterThan(rule.subPercent));
      expect(rule.mainPercent + rule.subPercent, 100);

      final String pair = '${rule.mainTraitId}/${rule.subTraitId}';
      expect(pairs.add(pair), true);
      expect(
        potionCatalog.any(
          (PotionBlueprint potion) => potion.id == rule.resultPotionId,
        ),
        true,
      );
    }
  });

  test('quality grade is calculated by target ratio score', () {
    final PotionBlueprint blueprint = potionCatalog.firstWhere(
      (PotionBlueprint p) => p.id == 'p_1',
    );

    final CraftedPotion high = service.craftPotion(
      requestedBlueprint: blueprint,
      extractedTraits: const <String, double>{'t_hp': 0.6, 't_atk': 0.4},
      recipeRules: potionRecipeCatalog,
      qualityRule: potionQualityCatalog,
    );
    final CraftedPotion low = service.craftPotion(
      requestedBlueprint: blueprint,
      extractedTraits: const <String, double>{'t_hp': 0.0, 't_atk': 1.0},
      recipeRules: potionRecipeCatalog,
      qualityRule: potionQualityCatalog,
    );

    expect(high.qualityGrade.index <= PotionQualityGrade.a.index, true);
    expect(low.qualityGrade, PotionQualityGrade.f);
    expect(high.qualityScore > low.qualityScore, true);
  });

  test('calculates quality from input traits', () {
    final PotionBlueprint blueprint = potionCatalog.firstWhere(
      (PotionBlueprint p) => p.id == 'p_1',
    );

    final ({PotionQualityGrade grade, double score}) high = service
        .calculateQualityFromTraits(
          targetTraits: blueprint.targetTraits,
          inputTraits: const <String, double>{'t_hp': 6, 't_atk': 4},
          qualityRule: potionQualityCatalog,
        );
    final ({PotionQualityGrade grade, double score}) low = service
        .calculateQualityFromTraits(
          targetTraits: blueprint.targetTraits,
          inputTraits: const <String, double>{'t_hp': 0, 't_atk': 1},
          qualityRule: potionQualityCatalog,
        );

    expect(high.grade, PotionQualityGrade.s);
    expect(low.grade, PotionQualityGrade.f);
    expect(high.score, greaterThan(low.score));
  });

  test('quality grade follows main ratio difference bands', () {
    final PotionBlueprint blueprint = potionCatalog.firstWhere(
      (PotionBlueprint p) => p.id == 'p_1',
    );

    final ({PotionQualityGrade grade, double score}) exact = service
        .calculateQualityFromTraits(
          targetTraits: blueprint.targetTraits,
          inputTraits: const <String, double>{'t_hp': 0.6, 't_atk': 0.4},
          qualityRule: potionQualityCatalog,
        );
    final ({PotionQualityGrade grade, double score}) near = service
        .calculateQualityFromTraits(
          targetTraits: blueprint.targetTraits,
          inputTraits: const <String, double>{'t_hp': 0.55, 't_atk': 0.45},
          qualityRule: potionQualityCatalog,
        );
    final ({PotionQualityGrade grade, double score}) medium = service
        .calculateQualityFromTraits(
          targetTraits: blueprint.targetTraits,
          inputTraits: const <String, double>{'t_hp': 0.5, 't_atk': 0.5},
          qualityRule: potionQualityCatalog,
        );
    final ({PotionQualityGrade grade, double score}) large = service
        .calculateQualityFromTraits(
          targetTraits: blueprint.targetTraits,
          inputTraits: const <String, double>{'t_hp': 0.35, 't_atk': 0.65},
          qualityRule: potionQualityCatalog,
        );
    final ({PotionQualityGrade grade, double score}) fail = service
        .calculateQualityFromTraits(
          targetTraits: blueprint.targetTraits,
          inputTraits: const <String, double>{'t_hp': 0.25, 't_atk': 0.75},
          qualityRule: potionQualityCatalog,
        );

    expect(exact.grade, PotionQualityGrade.s);
    expect(near.grade, PotionQualityGrade.a);
    expect(near.score, closeTo(0.9, 0.0001));
    expect(medium.grade, PotionQualityGrade.b);
    expect(medium.score, closeTo(0.8, 0.0001));
    expect(large.grade, PotionQualityGrade.c);
    expect(large.score, closeTo(0.5, 0.0001));
    expect(fail.grade, PotionQualityGrade.f);
    expect(fail.score, closeTo(0.3, 0.0001));
  });

  test('guard swift recipe grades against guard swift target ratio', () {
    final PotionBlueprint blueprint = potionCatalog.firstWhere(
      (PotionBlueprint p) => p.id == 'p_4',
    );

    final CraftedPotion optimal = service.craftPotion(
      requestedBlueprint: blueprint,
      extractedTraits: const <String, double>{'t_def': 0.65, 't_spd': 0.35},
      recipeRules: potionRecipeCatalog,
      qualityRule: potionQualityCatalog,
    );
    final CraftedPotion skewed = service.craftPotion(
      requestedBlueprint: blueprint,
      extractedTraits: const <String, double>{'t_def': 0.2, 't_spd': 0.8},
      recipeRules: potionRecipeCatalog,
      qualityRule: potionQualityCatalog,
    );

    expect(optimal.typePotionId, 'p_4');
    expect(optimal.qualityGrade, PotionQualityGrade.s);
    expect(skewed.typePotionId, 'p_4');
    expect(skewed.qualityGrade, PotionQualityGrade.f);
  });

  test('previewBrew returns hidden result hint state', () {
    final ({
      bool alreadyDiscovered,
      String hintLabel,
      String? predictedPotionId,
      double stability,
    })
    preview = service.previewBrew(
      inputTraits: const <String, double>{'t_hp': 7, 't_atk': 3},
      recipeRules: potionRecipeCatalog,
      discoveredPotionIds: const <String>{'p_1'},
    );

    expect(preview.predictedPotionId, 'p_1');
    expect(preview.hintLabel, '기록된 레시피와 유사');
    expect(preview.alreadyDiscovered, true);
    expect(preview.stability, closeTo(0.4, 0.0001));
  });

  test('prepareCraftFromExtractedInventory consumes matching traits', () {
    final PotionBlueprint blueprint = potionCatalog.firstWhere(
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
    final PotionBlueprint blueprint = potionCatalog.firstWhere(
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
