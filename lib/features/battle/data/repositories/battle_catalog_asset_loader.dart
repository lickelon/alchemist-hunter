import 'dart:convert';

import 'package:alchemist_hunter/features/battle/data/catalogs/battle_enemy_dtos.dart';
import 'package:alchemist_hunter/features/battle/data/catalogs/battle_stage_dtos.dart';
import 'package:alchemist_hunter/features/battle/data/catalogs/battle_combat_job_dtos.dart';
import 'package:alchemist_hunter/features/battle/data/catalogs/combat_passive_effect_dtos.dart';
import 'package:alchemist_hunter/features/battle/data/catalogs/combat_skill_dtos.dart';
import 'package:alchemist_hunter/features/battle/data/repositories/battle_catalog_tables.dart';
import 'package:flutter/services.dart';

class BattleCatalogAssetLoader {
  const BattleCatalogAssetLoader({this.assetRoot = 'assets/data/battle'});

  final String assetRoot;

  Future<BattleCatalogTables> load(AssetBundle bundle) async {
    final List<Map<String, Object?>> stageEntries = await _readObjectList(
      bundle,
      'stages.json',
    );
    return BattleCatalogTables.fromDtos(
      enemyDtos: _readDtoMap(
        await _readObjectList(bundle, 'enemies.json'),
        'enemies.json',
        BattleEnemyDefinitionDto.fromJson,
      ),
      enemySetDtos: _readDtoMap(
        await _readIndexedObjectLists(bundle, 'enemy_set_index.json'),
        'enemy_set_index.json',
        BattleEnemySetDefinitionDto.fromJson,
      ),
      stageDtos: _readDtoMap(
        stageEntries,
        'stages.json',
        BattleStageDefinitionDto.fromJson,
      ),
      stageCatalog: _readIds(stageEntries),
      combatJobDtos: _readDtoMap(
        await _readIndexedObjectList(bundle, 'combat_job_index.json'),
        'combat_job_index.json',
        BattleCombatJobDefinitionDto.fromJson,
      ),
      combatSkillDtos: _readDtoMap(
        await _readIndexedObjectLists(bundle, 'combat_skill_index.json'),
        'combat_skill_index.json',
        BattleSkillDefinitionDto.fromJson,
      ),
      combatPassiveDtos: _readDtoMap(
        await _readObjectList(bundle, 'combat_passives.json'),
        'combat_passives.json',
        BattlePassiveEffectDto.fromJson,
      ),
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

  List<String> _readIds(List<Map<String, Object?>> entries) {
    return entries.map(_readId).toList(growable: false);
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

  Future<List<Map<String, Object?>>> _readIndexedObjectList(
    AssetBundle bundle,
    String indexFileName,
  ) async {
    final List<String> fileNames = await _readStringList(bundle, indexFileName);
    final List<Map<String, Object?>> entries = <Map<String, Object?>>[];
    for (final String fileName in fileNames) {
      entries.add(await _readObject(bundle, fileName));
    }
    return entries;
  }

  Future<List<Map<String, Object?>>> _readIndexedObjectLists(
    AssetBundle bundle,
    String indexFileName,
  ) async {
    final List<String> fileNames = await _readStringList(bundle, indexFileName);
    final List<Map<String, Object?>> entries = <Map<String, Object?>>[];
    for (final String fileName in fileNames) {
      entries.addAll(await _readObjectList(bundle, fileName));
    }
    return entries;
  }

  Future<Map<String, Object?>> _readObject(
    AssetBundle bundle,
    String fileName,
  ) async {
    final Object? decoded = await _readJson(bundle, fileName);
    if (decoded is Map<String, Object?>) {
      return decoded;
    }
    throw FormatException('Battle catalog $fileName must be an object');
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
