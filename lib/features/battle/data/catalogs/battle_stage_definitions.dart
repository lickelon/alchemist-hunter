import 'battle_catalog_dtos.dart';

import 'encounters/stage_1_encounters.dart';
import 'encounters/stage_2_encounters.dart';
import 'encounters/stage_3_encounters.dart';
import 'encounters/stage_4_encounters.dart';
import 'encounters/stage_5_encounters.dart';

const Map<String, BattleStageDefinitionDto> battleStageDefinitionDtos =
    <String, BattleStageDefinitionDto>{
      'stage_1': BattleStageDefinitionDto(
        id: 'stage_1',
        name: '폐허 입구',
        recommendedPower: 210,
        searchDurationSeconds: 7,
        recoveryDurationSeconds: 10,
        encounters: stage1BattleStageEncounterDtos,
        goldSuccess: 24,
        goldFailurePenalty: 0,
        essenceSuccess: 4,
        essenceFailure: 0,
        xpSuccessBase: 16,
        xpFailureBase: 0,
        clearUnlockFlags: <String>{'stage_2'},
      ),
      'stage_2': BattleStageDefinitionDto(
        id: 'stage_2',
        name: '먼지 회랑',
        recommendedPower: 300,
        searchDurationSeconds: 9,
        recoveryDurationSeconds: 12,
        encounters: stage2BattleStageEncounterDtos,
        goldSuccess: 42,
        goldFailurePenalty: 0,
        essenceSuccess: 6,
        essenceFailure: 0,
        xpSuccessBase: 24,
        xpFailureBase: 0,
        unlockCondition: BattleStageUnlockConditionDto(
          requiredStageId: 'stage_1',
          requiredWinStreakCount: 3,
          label: '잠금 조건: 폐허 입구에서 실패 없이 3회 연속 승리',
        ),
        clearUnlockFlags: <String>{'stage_3'},
      ),
      'stage_3': BattleStageDefinitionDto(
        id: 'stage_3',
        name: '재의 공방',
        recommendedPower: 390,
        searchDurationSeconds: 11,
        recoveryDurationSeconds: 14,
        encounters: stage3BattleStageEncounterDtos,
        goldSuccess: 60,
        goldFailurePenalty: 0,
        essenceSuccess: 9,
        essenceFailure: 0,
        xpSuccessBase: 34,
        xpFailureBase: 0,
        unlockCondition: BattleStageUnlockConditionDto(
          requiredStageId: 'stage_2',
          requiredWinStreakCount: 3,
          label: '잠금 조건: 먼지 회랑에서 실패 없이 3회 연속 승리',
        ),
        clearUnlockFlags: <String>{'stage_4', 'potion_special_1'},
      ),
      'stage_4': BattleStageDefinitionDto(
        id: 'stage_4',
        name: '폭풍 전시실',
        recommendedPower: 490,
        searchDurationSeconds: 14,
        recoveryDurationSeconds: 16,
        encounters: stage4BattleStageEncounterDtos,
        goldSuccess: 86,
        goldFailurePenalty: 0,
        essenceSuccess: 13,
        essenceFailure: 0,
        xpSuccessBase: 46,
        xpFailureBase: 0,
        unlockCondition: BattleStageUnlockConditionDto(
          requiredStageId: 'stage_3',
          requiredWinStreakCount: 3,
          label: '잠금 조건: 재의 공방에서 실패 없이 3회 연속 승리',
        ),
        clearUnlockFlags: <String>{'stage_5'},
      ),
      'stage_5': BattleStageDefinitionDto(
        id: 'stage_5',
        name: '문물의 핵',
        recommendedPower: 580,
        searchDurationSeconds: 15,
        recoveryDurationSeconds: 18,
        encounters: stage5BattleStageEncounterDtos,
        goldSuccess: 112,
        goldFailurePenalty: 0,
        essenceSuccess: 18,
        essenceFailure: 0,
        xpSuccessBase: 58,
        xpFailureBase: 0,
        unlockCondition: BattleStageUnlockConditionDto(
          requiredStageId: 'stage_4',
          requiredWinStreakCount: 3,
          label: '잠금 조건: 폭풍 전시실에서 실패 없이 3회 연속 승리',
        ),
        clearUnlockFlags: <String>{'potion_special_2'},
      ),
    };

const List<String> stageCatalog = <String>[
  'stage_1',
  'stage_2',
  'stage_3',
  'stage_4',
  'stage_5',
];
