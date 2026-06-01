import 'package:alchemist_hunter/features/battle/domain/models.dart';
import 'package:flutter/foundation.dart';

import 'battle_catalog_json_helpers.dart';

@immutable
class BattleStageUnlockConditionDto {
  const BattleStageUnlockConditionDto({
    required this.requiredStageId,
    required this.requiredWinStreakCount,
    required this.label,
  });

  final String requiredStageId;
  final int requiredWinStreakCount;
  final String label;

  factory BattleStageUnlockConditionDto.fromJson(Map<String, Object?> json) {
    return BattleStageUnlockConditionDto(
      requiredStageId: readString(json, 'requiredStageId'),
      requiredWinStreakCount: readInt(json, 'requiredWinStreakCount'),
      label: readString(json, 'label'),
    );
  }

  BattleStageUnlockCondition toDomain() {
    return BattleStageUnlockCondition(
      requiredStageId: requiredStageId,
      requiredWinStreakCount: requiredWinStreakCount,
      label: label,
    );
  }
}

@immutable
class BattleStageEncounterDefinitionDto {
  const BattleStageEncounterDefinitionDto({
    required this.id,
    required this.enemySetId,
    required this.chance,
  });

  final String id;
  final String enemySetId;
  final double chance;

  factory BattleStageEncounterDefinitionDto.fromJson(
    Map<String, Object?> json,
  ) {
    return BattleStageEncounterDefinitionDto(
      id: readString(json, 'id'),
      enemySetId: readString(json, 'enemySetId'),
      chance: readDouble(json, 'chance'),
    );
  }

  BattleStageEncounterDefinition toDomain() {
    return BattleStageEncounterDefinition(
      id: id,
      enemySetId: enemySetId,
      chance: chance,
    );
  }
}

@immutable
class BattleStageDefinitionDto {
  const BattleStageDefinitionDto({
    required this.id,
    required this.name,
    required this.recommendedPower,
    required this.searchDurationSeconds,
    this.recoveryDurationSeconds = 10,
    required this.encounters,
    required this.goldSuccess,
    required this.goldFailurePenalty,
    required this.essenceSuccess,
    required this.essenceFailure,
    required this.xpSuccessBase,
    required this.xpFailureBase,
    this.unlockCondition,
    this.clearUnlockFlags = const <String>{},
  });

  final String id;
  final String name;
  final int recommendedPower;
  final int searchDurationSeconds;
  final int recoveryDurationSeconds;
  final List<BattleStageEncounterDefinitionDto> encounters;
  final int goldSuccess;
  final int goldFailurePenalty;
  final int essenceSuccess;
  final int essenceFailure;
  final int xpSuccessBase;
  final int xpFailureBase;
  final BattleStageUnlockConditionDto? unlockCondition;
  final Set<String> clearUnlockFlags;

  factory BattleStageDefinitionDto.fromJson(Map<String, Object?> json) {
    return BattleStageDefinitionDto(
      id: readString(json, 'id'),
      name: readString(json, 'name'),
      recommendedPower: readInt(json, 'recommendedPower'),
      searchDurationSeconds: readInt(json, 'searchDurationSeconds'),
      recoveryDurationSeconds: readInt(
        json,
        'recoveryDurationSeconds',
        fallback: 10,
      ),
      encounters: readList(
        json,
        'encounters',
        BattleStageEncounterDefinitionDto.fromJson,
      ),
      goldSuccess: readInt(json, 'goldSuccess'),
      goldFailurePenalty: readInt(json, 'goldFailurePenalty'),
      essenceSuccess: readInt(json, 'essenceSuccess'),
      essenceFailure: readInt(json, 'essenceFailure'),
      xpSuccessBase: readInt(json, 'xpSuccessBase'),
      xpFailureBase: readInt(json, 'xpFailureBase'),
      unlockCondition: readOptionalMap(
        json,
        'unlockCondition',
        BattleStageUnlockConditionDto.fromJson,
      ),
      clearUnlockFlags: readStringList(json, 'clearUnlockFlags').toSet(),
    );
  }

  BattleStageDefinition toDomain() {
    return BattleStageDefinition(
      id: id,
      name: name,
      recommendedPower: recommendedPower,
      searchDuration: Duration(seconds: searchDurationSeconds),
      recoveryDuration: Duration(seconds: recoveryDurationSeconds),
      encounters: encounters
          .map(
            (BattleStageEncounterDefinitionDto encounter) =>
                encounter.toDomain(),
          )
          .toList(growable: false),
      goldSuccess: goldSuccess,
      goldFailurePenalty: goldFailurePenalty,
      essenceSuccess: essenceSuccess,
      essenceFailure: essenceFailure,
      xpSuccessBase: xpSuccessBase,
      xpFailureBase: xpFailureBase,
      unlockCondition: unlockCondition?.toDomain(),
      clearUnlockFlags: clearUnlockFlags,
    );
  }
}
