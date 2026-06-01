import 'dart:convert';

import 'package:alchemist_hunter/core/catalog/json_catalog_helpers.dart' as j;
import 'package:alchemist_hunter/features/battle/data/catalogs/battle_catalog_dtos.dart';
import 'package:alchemist_hunter/features/battle/domain/models.dart';
import 'package:alchemist_hunter/features/town/data/repositories/town_catalog_data.dart';
import 'package:alchemist_hunter/features/town/domain/models.dart';
import 'package:flutter/services.dart';

class TownCatalogAssetLoader {
  const TownCatalogAssetLoader({this.assetRoot = 'assets/data/town'});

  final String assetRoot;

  Future<TownCatalogAssets> load(AssetBundle bundle) async {
    final Map<String, Object?> shops = await _readObject(bundle, 'shops.json');
    final Map<String, Object?> equipment = await _readObject(
      bundle,
      'equipment.json',
    );
    return TownCatalogAssets(
      shopCatalog: _readShopCatalog(shops),
      equipmentBlueprints: j
          .readObjectList(equipment, 'equipmentBlueprints')
          .map(_readEquipmentBlueprint)
          .toList(growable: false),
      equipmentMaterialNames: _readStringMap(
        equipment,
        'equipmentMaterialNames',
      ),
      mercenaryTemplates: (await _readObjectList(
        bundle,
        'mercenaries.json',
      )).map(_readMercenaryTemplate).toList(growable: false),
      skillNodes: (await _readObjectList(
        bundle,
        'skill_tree.json',
      )).map(_readTownSkillNode).toList(growable: false),
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
    throw FormatException('Town catalog $fileName must be an object');
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
              'Town catalog $fileName entry must be object',
            );
          })
          .toList(growable: false);
    }
    throw FormatException('Town catalog $fileName must be a list');
  }

  Future<Object?> _readJson(AssetBundle bundle, String fileName) async {
    final String source = await bundle.loadString('$assetRoot/$fileName');
    return jsonDecode(source);
  }

  ShopCatalogData _readShopCatalog(Map<String, Object?> json) {
    return ShopCatalogData(
      general: _readShopDefinition(
        j.readObject(json, 'general'),
        ShopType.general,
      ),
      catalyst: _readShopDefinition(
        j.readObject(json, 'catalyst'),
        ShopType.catalyst,
      ),
    );
  }

  ShopDefinitionData _readShopDefinition(
    Map<String, Object?> json,
    ShopType shopType,
  ) {
    return ShopDefinitionData(
      shopType: shopType,
      seedItems: j
          .readObjectList(json, 'items')
          .map(_readShopItem)
          .toList(growable: false),
      refreshInterval: Duration(
        seconds: j.readInt(json, 'refreshIntervalSeconds'),
      ),
      purchaseLimitPerItem: j.readInt(json, 'purchaseLimitPerItem'),
      baseRefreshCost: j.readInt(json, 'baseRefreshCost'),
      refreshCostStep: j.readInt(json, 'refreshCostStep'),
    );
  }

  ShopItem _readShopItem(Map<String, Object?> json) {
    return ShopItem(
      materialId: j.readString(json, 'materialId'),
      name: j.readString(json, 'name'),
      price: j.readInt(json, 'price'),
      quantity: j.readInt(json, 'quantity'),
    );
  }

  EquipmentBlueprint _readEquipmentBlueprint(Map<String, Object?> json) {
    return EquipmentBlueprint(
      id: j.readString(json, 'id'),
      name: j.readString(json, 'name'),
      slot: j.readEnum(json, 'slot', EquipmentSlot.values),
      materialCosts: j.readIntMap(json, 'materialCosts'),
      craftDuration: Duration(
        seconds: j.readInt(json, 'craftDurationSeconds', fallback: 30),
      ),
      maxHp: j.readInt(json, 'maxHp', fallback: 0),
      physicalAttack: j.readInt(json, 'physicalAttack', fallback: 0),
      physicalDefense: j.readInt(json, 'physicalDefense', fallback: 0),
      magicalAttack: j.readInt(json, 'magicalAttack', fallback: 0),
      magicalDefense: j.readInt(json, 'magicalDefense', fallback: 0),
      speed: j.readInt(json, 'speed', fallback: 0),
      statModifiers: j
          .readObjectList(json, 'statModifiers')
          .map(_readBattleStatModifier)
          .toList(growable: false),
      modifiers: j
          .readObjectList(json, 'modifiers')
          .map(BattleModifierDto.fromJson)
          .map((BattleModifierDto dto) => dto.toDomain())
          .toList(growable: false),
      passives: j
          .readObjectList(json, 'passives')
          .map(BattlePassiveEffectDto.fromJson)
          .map((BattlePassiveEffectDto dto) => dto.toDomain())
          .toList(growable: false),
    );
  }

  BattleStatModifier _readBattleStatModifier(Map<String, Object?> json) {
    return BattleStatModifier(
      type: j.readEnum(json, 'type', BattleStatModifierType.values),
      mode: j.readEnum(json, 'mode', BattleModifierMode.values),
      value: j.readDouble(json, 'value'),
      sourceId: j.readString(json, 'sourceId'),
    );
  }

  MercenaryTemplate _readMercenaryTemplate(Map<String, Object?> json) {
    return MercenaryTemplate(
      id: j.readString(json, 'id'),
      name: j.readString(json, 'name'),
      roleLabel: j.readString(json, 'roleLabel'),
      combatJobId: j.readString(json, 'combatJobId'),
      hireCost: j.readInt(json, 'hireCost'),
      tierIndex: j.readInt(json, 'tierIndex'),
    );
  }

  TownSkillNode _readTownSkillNode(Map<String, Object?> json) {
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
                .map(_readTownSkillCost)
                .toList(growable: false);
          })
          .toList(growable: false),
      prerequisiteNodeIds: j.readStringList(json, 'prerequisiteNodeIds'),
      requirements: j
          .readObjectList(json, 'requirements')
          .map(_readTownSkillRequirement)
          .toList(growable: false),
      effects: j
          .readObjectList(json, 'effects')
          .map(_readTownSkillEffect)
          .toList(growable: false),
    );
  }

  TownSkillCost _readTownSkillCost(Map<String, Object?> json) {
    return TownSkillCost(
      type: j.readEnum(json, 'type', TownSkillCostType.values),
      amount: j.readInt(json, 'amount'),
    );
  }

  TownSkillRequirement _readTownSkillRequirement(Map<String, Object?> json) {
    return TownSkillRequirement(
      type: j.readEnum(json, 'type', TownSkillRequirementType.values),
      threshold: j.readInt(json, 'threshold'),
      label: j.readString(json, 'label'),
    );
  }

  TownSkillEffect _readTownSkillEffect(Map<String, Object?> json) {
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

  Map<String, String> _readStringMap(Map<String, Object?> json, String key) {
    final Object? value = json[key];
    if (value is Map<String, Object?>) {
      return value.map((String key, Object? entry) {
        if (entry is String) {
          return MapEntry<String, String>(key, entry);
        }
        throw FormatException('Invalid string map entry for $key: $entry');
      });
    }
    throw FormatException('Invalid string map value for $key: $value');
  }
}
