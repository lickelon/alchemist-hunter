import 'dart:convert';

import 'package:alchemist_hunter/core/catalog/json_catalog_helpers.dart' as j;
import 'package:alchemist_hunter/features/workshop/data/repositories/workshop_catalog_data.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:flutter/services.dart';

class WorkshopCatalogAssetLoader {
  const WorkshopCatalogAssetLoader({this.assetRoot = 'assets/data/workshop'});

  final String assetRoot;

  Future<WorkshopCatalogAssets> load(AssetBundle bundle) async {
    final List<TraitUnit> traits = (await _readObjectList(
      bundle,
      'traits.json',
    )).map(_readTrait).toList(growable: false);
    final Map<String, TraitUnit> traitsById = <String, TraitUnit>{
      for (final TraitUnit trait in traits) trait.id: trait,
    };
    return WorkshopCatalogAssets(
      traits: traits,
      materials: (await _readObjectList(bundle, 'materials.json'))
          .map((Map<String, Object?> json) => _readMaterial(json, traitsById))
          .toList(growable: false),
      extractionProfiles: (await _readObjectList(
        bundle,
        'extraction_profiles.json',
      )).map(_readExtractionProfile).toList(growable: false),
      potions: (await _readObjectList(
        bundle,
        'potions.json',
      )).map(_readPotion).toList(growable: false),
      potionRecipeRules: (await _readObjectList(
        bundle,
        'potion_recipes.json',
      )).map(_readPotionRecipeRule).toList(growable: false),
      potionQualityRule: _readPotionQualityRule(
        await _readObject(bundle, 'potion_quality.json'),
      ),
      craftRecipes: (await _readObjectList(
        bundle,
        'craft_recipes.json',
      )).map(_readCraftRecipe).toList(growable: false),
      hatchRecipes: (await _readObjectList(
        bundle,
        'hatch_recipes.json',
      )).map(_readHatchRecipe).toList(growable: false),
      skillNodes: (await _readObjectList(
        bundle,
        'skill_tree.json',
      )).map(_readWorkshopSkillNode).toList(growable: false),
    );
  }

  Future<Map<String, Object?>> _readObject(
    AssetBundle bundle,
    String fileName,
  ) async {
    final Object? decoded = await _readJson(bundle, fileName);
    if (decoded is Map<String, Object?>) {
      return decoded;
    }
    throw FormatException('Workshop catalog $fileName must be an object');
  }

  Future<List<Map<String, Object?>>> _readObjectList(
    AssetBundle bundle,
    String fileName,
  ) async {
    final Object? decoded = await _readJson(bundle, fileName);
    if (decoded is List<Object?>) {
      return decoded
          .map((Object? entry) {
            if (entry is Map<String, Object?>) {
              return entry;
            }
            throw FormatException(
              'Workshop catalog $fileName entry must be object',
            );
          })
          .toList(growable: false);
    }
    throw FormatException('Workshop catalog $fileName must be a list');
  }

  Future<Object?> _readJson(AssetBundle bundle, String fileName) async {
    final String source = await bundle.loadString('$assetRoot/$fileName');
    return jsonDecode(source);
  }

  TraitUnit _readTrait(Map<String, Object?> json) {
    return TraitUnit(
      id: j.readString(json, 'id'),
      name: j.readString(json, 'name'),
      type: j.readEnum(json, 'type', TraitType.values),
      potency: j.readDouble(json, 'potency'),
      components: j.readDoubleMap(json, 'components'),
    );
  }

  MaterialEntity _readMaterial(
    Map<String, Object?> json,
    Map<String, TraitUnit> traitsById,
  ) {
    return MaterialEntity(
      id: j.readString(json, 'id'),
      name: j.readString(json, 'name'),
      rarity: j.readEnum(json, 'rarity', MaterialRarity.values),
      traits: j
          .readStringList(json, 'traitIds')
          .map((String traitId) {
            final TraitUnit? trait = traitsById[traitId];
            if (trait == null) {
              throw StateError('Unknown material trait: $traitId');
            }
            return trait;
          })
          .toList(growable: false),
      analyzable: j.readBool(json, 'analyzable'),
      source: j.readString(json, 'source'),
    );
  }

  ExtractionProfile _readExtractionProfile(Map<String, Object?> json) {
    return ExtractionProfile(
      id: j.readString(json, 'id'),
      mode: j.readEnum(json, 'mode', ExtractionMode.values),
      yieldRate: j.readDouble(json, 'yieldRate'),
      purityRate: j.readDouble(json, 'purityRate'),
      timeCost: Duration(seconds: j.readInt(json, 'timeCostSeconds')),
    );
  }

  PotionBlueprint _readPotion(Map<String, Object?> json) {
    return PotionBlueprint(
      id: j.readString(json, 'id'),
      name: j.readString(json, 'name'),
      targetTraits: j.readDoubleMap(json, 'targetTraits'),
      baseValue: j.readInt(json, 'baseValue'),
      useType: j.readEnum(json, 'useType', PotionUseType.values),
    );
  }

  PotionRecipeRule _readPotionRecipeRule(Map<String, Object?> json) {
    return PotionRecipeRule(
      id: j.readString(json, 'id'),
      mainTraitId: j.readString(json, 'mainTraitId'),
      subTraitId: j.readString(json, 'subTraitId'),
      mainPercent: j.readInt(json, 'mainPercent'),
      subPercent: j.readInt(json, 'subPercent'),
      resultPotionId: j.readString(json, 'resultPotionId'),
    );
  }

  PotionQualityRule _readPotionQualityRule(Map<String, Object?> json) {
    final Map<String, double> thresholds = j.readDoubleMap(
      json,
      'gradeThresholds',
    );
    return PotionQualityRule(
      gradeThresholds: thresholds.map((String key, double value) {
        final PotionQualityGrade grade = PotionQualityGrade.values.firstWhere(
          (PotionQualityGrade grade) => grade.name == key,
        );
        return MapEntry<PotionQualityGrade, double>(grade, value);
      }),
    );
  }

  WorkshopCraftRecipe _readCraftRecipe(Map<String, Object?> json) {
    return WorkshopCraftRecipe(
      id: j.readString(json, 'id'),
      name: j.readString(json, 'name'),
      category: j.readEnum(
        json,
        'category',
        WorkshopCraftRecipeCategory.values,
      ),
      materialCosts: j.readIntMap(json, 'materialCosts'),
      traitCosts: j.readDoubleMap(json, 'traitCosts'),
      essenceCost: j.readInt(json, 'essenceCost', fallback: 0),
      arcaneDustCost: j.readInt(json, 'arcaneDustCost', fallback: 0),
      duration: Duration(seconds: j.readInt(json, 'durationSeconds')),
      resultMaterials: j.readIntMap(json, 'resultMaterials'),
    );
  }

  HomunculusHatchRecipe _readHatchRecipe(Map<String, Object?> json) {
    return HomunculusHatchRecipe(
      id: j.readString(json, 'id'),
      name: j.readString(json, 'name'),
      description: j.readString(json, 'description'),
      resultName: j.readString(json, 'resultName'),
      roleLabel: j.readString(json, 'roleLabel'),
      combatJobId: j.readString(json, 'combatJobId'),
      supportEffectLabel: j.readString(json, 'supportEffectLabel'),
      essenceCost: j.readInt(json, 'essenceCost'),
      arcaneDustCost: j.readInt(json, 'arcaneDustCost'),
      materialCosts: j.readIntMap(json, 'materialCosts'),
      traitCosts: j.readDoubleMap(json, 'traitCosts'),
      duration: Duration(seconds: j.readInt(json, 'durationSeconds')),
    );
  }

  WorkshopSkillNode _readWorkshopSkillNode(Map<String, Object?> json) {
    return WorkshopSkillNode(
      id: j.readString(json, 'id'),
      name: j.readString(json, 'name'),
      description: j.readString(json, 'description'),
      maxLevel: j.readInt(json, 'maxLevel'),
      costsByLevel: j
          .readObjectList(json, 'costsByLevel')
          .map((Map<String, Object?> level) {
            return j
                .readObjectList(level, 'costs')
                .map(_readWorkshopSkillCost)
                .toList(growable: false);
          })
          .toList(growable: false),
      prerequisiteNodeIds: j.readStringList(json, 'prerequisiteNodeIds'),
      requirements: j
          .readObjectList(json, 'requirements')
          .map(_readWorkshopSkillRequirement)
          .toList(growable: false),
      effects: j
          .readObjectList(json, 'effects')
          .map(_readWorkshopSkillEffect)
          .toList(growable: false),
    );
  }

  WorkshopSkillCost _readWorkshopSkillCost(Map<String, Object?> json) {
    return WorkshopSkillCost(
      type: j.readEnum(json, 'type', WorkshopSkillCostType.values),
      amount: j.readInt(json, 'amount'),
      elementId: json['elementId'] == null
          ? null
          : j.readString(json, 'elementId'),
    );
  }

  WorkshopSkillRequirement _readWorkshopSkillRequirement(
    Map<String, Object?> json,
  ) {
    return WorkshopSkillRequirement(
      type: j.readEnum(json, 'type', WorkshopSkillRequirementType.values),
      threshold: j.readInt(json, 'threshold'),
      label: j.readString(json, 'label'),
    );
  }

  WorkshopSkillEffect _readWorkshopSkillEffect(Map<String, Object?> json) {
    return WorkshopSkillEffect(
      type: j.readEnum(json, 'type', WorkshopSkillEffectType.values),
      modifierType: j.readEnum(
        json,
        'modifierType',
        WorkshopSkillModifierType.values,
      ),
      value: j.readDouble(json, 'value'),
      label: j.readString(json, 'label'),
    );
  }
}
