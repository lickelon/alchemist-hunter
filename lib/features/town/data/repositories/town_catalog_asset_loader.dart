import 'dart:convert';

import 'package:alchemist_hunter/core/catalog/json_catalog_helpers.dart' as j;
import 'package:alchemist_hunter/features/battle/domain/models.dart';
import 'package:alchemist_hunter/features/town/data/repositories/town_catalog_data.dart';
import 'package:alchemist_hunter/features/town/domain/models.dart';
import 'package:flutter/services.dart';

part 'town_catalog_asset_reader.dart';
part 'town_equipment_catalog_parser.dart';
part 'town_mercenary_catalog_parser.dart';
part 'town_shop_catalog_parser.dart';
part 'town_skill_tree_catalog_parser.dart';

class TownCatalogAssetLoader
    with
        _TownCatalogAssetReaderMixin,
        _TownShopCatalogParserMixin,
        _TownEquipmentCatalogParserMixin,
        _TownMercenaryCatalogParserMixin,
        _TownSkillTreeCatalogParserMixin {
  const TownCatalogAssetLoader({this.assetRoot = 'assets/data/town'});

  @override
  final String assetRoot;

  Future<TownCatalogAssets> load(AssetBundle bundle) async {
    final Map<String, Object?> shops = await readObject(bundle, 'shops.json');
    final Map<String, Object?> equipment = await readObject(
      bundle,
      'equipment.json',
    );
    return TownCatalogAssets(
      shopCatalog: readShopCatalog(shops),
      equipmentBlueprints: j
          .readObjectList(equipment, 'equipmentBlueprints')
          .map(readEquipmentBlueprint)
          .toList(growable: false),
      equipmentMaterialNames: readStringMap(
        equipment,
        'equipmentMaterialNames',
      ),
      mercenaryTemplates: (await readObjectList(
        bundle,
        'mercenaries.json',
      )).map(readMercenaryTemplate).toList(growable: false),
      skillNodes: (await readObjectList(
        bundle,
        'skill_tree.json',
      )).map(readTownSkillNode).toList(growable: false),
    );
  }
}
