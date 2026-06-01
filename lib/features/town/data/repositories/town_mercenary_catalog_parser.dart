part of 'town_catalog_asset_loader.dart';

mixin _TownMercenaryCatalogParserMixin {
  MercenaryTemplate readMercenaryTemplate(Map<String, Object?> json) {
    return MercenaryTemplate(
      id: j.readString(json, 'id'),
      name: j.readString(json, 'name'),
      roleLabel: j.readString(json, 'roleLabel'),
      combatJobId: j.readString(json, 'combatJobId'),
      hireCost: j.readInt(json, 'hireCost'),
      tierIndex: j.readInt(json, 'tierIndex'),
    );
  }
}
