import 'dart:convert';

import 'package:alchemist_hunter/features/battle/data/catalogs/battle_catalog_dtos.dart';
import 'package:alchemist_hunter/features/battle/data/repositories/battle_catalog_tables.dart';
import 'package:flutter/services.dart';

class BattleCatalogAssetLoader {
  const BattleCatalogAssetLoader({this.assetRoot = 'assets/data/battle'});

  final String assetRoot;

  Future<BattleCatalogTables> load(AssetBundle bundle) async {
    return BattleCatalogTables.fromDtos(
      enemyDtos: _readDtoMap(
        await _readObjectList(bundle, 'enemies.json'),
        'enemies.json',
        BattleEnemyDefinitionDto.fromJson,
      ),
      enemySetDtos: _readDtoMap(
        await _readObjectList(bundle, 'enemy_sets.json'),
        'enemy_sets.json',
        BattleEnemySetDefinitionDto.fromJson,
      ),
      stageDtos: _readDtoMap(
        await _readObjectList(bundle, 'stages.json'),
        'stages.json',
        BattleStageDefinitionDto.fromJson,
      ),
      stageCatalog: await _readStringList(bundle, 'stage_catalog.json'),
    );
  }

  Map<String, T> _readDtoMap<T>(
    List<Map<String, Object?>> entries,
    String label,
    T Function(Map<String, Object?> json) convert,
  ) {
    return <String, T>{
      for (final Map<String, Object?> entry in entries)
        _readId(entry): convert(entry),
    };
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
              'Battle catalog $fileName entry must be object',
            );
          })
          .toList(growable: false);
    }
    throw FormatException('Battle catalog $fileName must be a list');
  }

  Future<List<String>> _readStringList(
    AssetBundle bundle,
    String fileName,
  ) async {
    final Object? decoded = await _readJson(bundle, fileName);
    if (decoded is List<Object?>) {
      return decoded
          .map((Object? entry) {
            if (entry is String) {
              return entry;
            }
            throw FormatException(
              'Battle catalog $fileName entry must be a string',
            );
          })
          .toList(growable: false);
    }
    throw FormatException('Battle catalog $fileName must be a list');
  }

  Future<Object?> _readJson(AssetBundle bundle, String fileName) async {
    final String source = await bundle.loadString('$assetRoot/$fileName');
    return jsonDecode(source);
  }

  String _readId(Map<String, Object?> json) {
    final Object? value = json['id'];
    if (value is String) {
      return value;
    }
    throw FormatException('Battle catalog entry must define an id: $json');
  }
}
