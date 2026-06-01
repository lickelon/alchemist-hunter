part of 'town_catalog_asset_loader.dart';

mixin _TownSkillTreeCatalogParserMixin {
  TownSkillNode readTownSkillNode(Map<String, Object?> json) {
    return TownSkillNode(
      id: j.readString(json, 'id'),
      name: j.readString(json, 'name'),
      description: j.readString(json, 'description'),
      maxLevel: j.readInt(json, 'maxLevel'),
      costsByLevel: j
          .readObjectList(json, 'costsByLevel')
          .map((Map<String, Object?> level) {
            return j
                .readObjectList(level, 'costs')
                .map(readTownSkillCost)
                .toList(growable: false);
          })
          .toList(growable: false),
      prerequisiteNodeIds: j.readStringList(json, 'prerequisiteNodeIds'),
      requirements: j
          .readObjectList(json, 'requirements')
          .map(readTownSkillRequirement)
          .toList(growable: false),
      effects: j
          .readObjectList(json, 'effects')
          .map(readTownSkillEffect)
          .toList(growable: false),
    );
  }

  TownSkillCost readTownSkillCost(Map<String, Object?> json) {
    return TownSkillCost(
      type: j.readEnum(json, 'type', TownSkillCostType.values),
      amount: j.readInt(json, 'amount'),
    );
  }

  TownSkillRequirement readTownSkillRequirement(Map<String, Object?> json) {
    return TownSkillRequirement(
      type: j.readEnum(json, 'type', TownSkillRequirementType.values),
      threshold: j.readInt(json, 'threshold'),
      label: j.readString(json, 'label'),
    );
  }

  TownSkillEffect readTownSkillEffect(Map<String, Object?> json) {
    return TownSkillEffect(
      type: j.readEnum(json, 'type', TownSkillEffectType.values),
      modifierType: j.readEnum(
        json,
        'modifierType',
        TownSkillModifierType.values,
      ),
      value: j.readDouble(json, 'value'),
      label: j.readString(json, 'label'),
    );
  }
}
