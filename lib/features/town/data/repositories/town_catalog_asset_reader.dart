part of 'town_catalog_asset_loader.dart';

mixin _TownCatalogAssetReaderMixin {
  String get assetRoot;

  Future<Map<String, Object?>> readObject(
    AssetBundle bundle,
    String fileName,
  ) async {
    final Object? decoded = await readJson(bundle, fileName);
    if (decoded is Map<String, Object?>) {
      return decoded;
    }
    throw FormatException('Town catalog $fileName must be an object');
  }

  Future<List<Map<String, Object?>>> readObjectList(
    AssetBundle bundle,
    String fileName,
  ) async {
    final Object? decoded = await readJson(bundle, fileName);
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

  Future<Object?> readJson(AssetBundle bundle, String fileName) async {
    final String source = await bundle.loadString('$assetRoot/$fileName');
    return jsonDecode(source);
  }
}
