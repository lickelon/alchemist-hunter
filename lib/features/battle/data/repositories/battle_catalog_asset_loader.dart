import 'dart:convert';

import 'package:alchemist_hunter/features/battle/data/catalogs/battle_catalog_dtos.dart';
import 'package:alchemist_hunter/features/battle/data/catalogs/battle_tables.dart';
import 'package:flutter/services.dart';

class BattleCatalogAssetLoader {
  const BattleCatalogAssetLoader({
    this.assetPath = 'assets/data/battle_catalog.json',
  });

  final String assetPath;

  Future<BattleCatalogTables> load(AssetBundle bundle) async {
    final String source = await bundle.loadString(assetPath);
    final Object? decoded = jsonDecode(source);
    if (decoded is! Map<String, Object?>) {
      throw const FormatException('Battle catalog root must be an object');
    }
    return BattleCatalogTables.fromDtos(
      enemyDtos: _readDtoMap(
        decoded,
        'enemies',
        BattleEnemyDefinitionDto.fromJson,
      ),
      enemySetDtos: _readDtoMap(
        decoded,
        'enemySets',
        BattleEnemySetDefinitionDto.fromJson,
      ),
      stageDtos: _readDtoMap(
        decoded,
        'stages',
        BattleStageDefinitionDto.fromJson,
      ),
      stageCatalog: _readStringList(decoded, 'stageCatalog'),
    );
  }

  Map<String, T> _readDtoMap<T>(
    Map<String, Object?> json,
    String key,
    T Function(Map<String, Object?> json) convert,
  ) {
    final Object? value = json[key];
    if (value is! List<Object?>) {
      throw FormatException('Battle catalog $key must be a list');
    }
    return <String, T>{
      for (final Map<String, Object?> entry in value.map(
        (Object? entry) => _readObjectEntry(key, entry),
      ))
        _readId(entry): convert(entry),
    };
  }

  Map<String, Object?> _readObjectEntry(String key, Object? entry) {
    if (entry is Map<String, Object?>) {
      return entry;
    }
    throw FormatException('Battle catalog $key entry must be an object');
  }

  List<String> _readStringList(Map<String, Object?> json, String key) {
    final Object? value = json[key];
    if (value is! List<Object?>) {
      throw FormatException('Battle catalog $key must be a list');
    }
    return value
        .map((Object? entry) {
          if (entry is String) {
            return entry;
          }
          throw FormatException('Battle catalog $key entry must be a string');
        })
        .toList(growable: false);
  }

  String _readId(Map<String, Object?> json) {
    final Object? value = json['id'];
    if (value is String) {
      return value;
    }
    throw FormatException('Battle catalog entry must define an id: $json');
  }
}
