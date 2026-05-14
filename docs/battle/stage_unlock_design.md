# Stage Unlock 설계

## 1. 목적

이전 stage 해금은 `이전 stage 클리어` 기반 임시 규칙이었다. 현재 기준은 이전 stage를 실패 없이 일정 횟수 연속 성공했을 때 다음 stage가 열리는 구조다.

이 문서는 현재 구현과 이후 확장의 기준 문서다.

## 2. 핵심 규칙

다음 stage는 이전 stage의 무실패 연속 승리 수가 요구치에 도달하면 해금된다.

예시:

| 대상 stage | 기준 stage | 조건 |
| --- | --- | --- |
| Stage 2 | Stage 1 | Stage 1에서 실패 없이 연속 승리 N회 |
| Stage 3 | Stage 2 | Stage 2에서 실패 없이 연속 승리 N회 |
| Stage 4 | Stage 3 | Stage 3에서 실패 없이 연속 승리 N회 |
| Stage 5 | Stage 4 | Stage 4에서 실패 없이 연속 승리 N회 |

`N`은 stage catalog의 튜닝 값으로 둔다. 초기 구현에서는 stage별로 다른 값을 둘 수 있게 모델만 열어둔다.

## 3. 승리 / 실패 정의

### 승리

아래 조건을 만족하면 해당 stage의 연속 승리 수를 1 증가시킨다.

- encounter가 `success == true`로 종료된다.
- 보상이 pending claim에 누적되는 정상 성공이다.
- 성공 encounter XP가 즉시 반영되는 경로와 같은 이벤트를 사용한다.

### 실패

아래 조건이면 해당 stage의 현재 연속 승리 수를 0으로 초기화한다.

- encounter가 `success == false`로 종료된다.
- 전멸로 `recovering`에 들어간다.
- 전멸이 아니더라도 실패 로그가 기록된다.

### 연속성 유지

아래 상황은 연속 승리 수를 초기화하지 않는다.

- 탐색 중
- 복구 완료 후 다음 탐색 진입
- 원정 일시정지
- 보상 수령
- 앱 sync / 시간 가속
- 포션 부족 fallback 상태에서 전투를 성공한 경우

포션 부족 fallback은 해금 실패 사유가 아니다. 전투가 성공하면 연속 승리로 인정한다.

## 4. 영구 해금 규칙

해금은 한 번 열리면 영구 유지한다.

- 요구 streak 달성 시 대상 stage를 해금 상태로 기록한다.
- 이후 기준 stage에서 실패해도 이미 열린 stage를 다시 잠그지 않는다.
- 따라서 UI 잠금 판정은 `현재 streak`만 보지 말고 `이미 해금된 stage` 상태를 함께 봐야 한다.

권장 상태는 아래 중 하나다.

| 상태 | 용도 |
| --- | --- |
| `unlockedStageIds` | 영구 해금된 stage 기록 |
| `stageCurrentWinStreaks` | 현재 연속 승리 수 |
| `stageBestWinStreaks` | 최고 연속 승리 수, UI 진행도 표시용 |

현재 `clearedStageIds`는 기존 임시 구현 호환용으로만 본다. 새 설계에서는 `clearedStageIds`를 해금의 최종 의미로 확장하지 않는다.

## 5. 금지 규칙

재료 기반 해금은 사용하지 않는다.

- 특정 재료 보유
- 특정 재료 소비
- 상점 구매 재료 조건
- stage 외부 재료 파밍 여부

해금은 battle 내부 진행도로만 판단한다. 재료는 제작과 성장의 자원이지 stage unlock key가 아니다.

## 6. 요구 조건 후보

이번 1차 구현의 기본 요구 조건은 `previousStageWinStreak`다. 아래 후보는 확장 가능성을 위해 타입으로 남긴다.

| 타입 | 설명 | 이번 적용 |
| --- | --- | --- |
| `previousStageWinStreak` | 이전 stage에서 무실패 연속 승리 N회 | 기본 |
| `stageClear` | 특정 stage 클리어 | legacy 호환 |
| `encounterClear` | 특정 encounter 클리어 | 후보 |
| `stageVictoryCount` | 특정 stage 누적 승리 수 | 후보 |
| `bossEncounterClear` | 보스 encounter 클리어 | 보스 구현 후 |
| `recommendedPower` | 권장 전투력 도달 | 후보 |

## 7. 모델 초안

```dart
enum BattleUnlockRequirementType {
  previousStageWinStreak,
  stageClear,
  encounterClear,
  stageVictoryCount,
  bossEncounterClear,
  recommendedPower,
}

class BattleUnlockRequirement {
  const BattleUnlockRequirement({
    required this.type,
    required this.label,
    this.stageId,
    this.encounterId,
    this.requiredCount = 1,
    this.requiredPower,
  });

  final BattleUnlockRequirementType type;
  final String label;
  final String? stageId;
  final String? encounterId;
  final int requiredCount;
  final int? requiredPower;
}

class BattleStageUnlockRule {
  const BattleStageUnlockRule({
    required this.stageId,
    this.allOf = const <BattleUnlockRequirement>[],
    this.anyOf = const <BattleUnlockRequirement>[],
  });

  final String stageId;
  final List<BattleUnlockRequirement> allOf;
  final List<BattleUnlockRequirement> anyOf;
}
```

## 8. 조합 규칙

기본은 `allOf`다.

- `allOf`가 비어 있으면 해당 stage는 기본 해금 상태다.
- `allOf`는 모든 조건을 만족해야 한다.
- `anyOf`는 향후 이벤트성 또는 대체 경로가 필요할 때만 사용한다.
- `allOf`와 `anyOf`를 동시에 쓰는 경우 `allOf`는 항상 만족해야 하고, `anyOf` 중 하나를 추가로 만족해야 한다.

초기 stage unlock은 아래처럼 표현한다.

```dart
BattleStageUnlockRule(
  stageId: 'stage_2',
  allOf: <BattleUnlockRequirement>[
    BattleUnlockRequirement(
      type: BattleUnlockRequirementType.previousStageWinStreak,
      stageId: 'stage_1',
      requiredCount: 3,
      label: '1단계에서 실패 없이 3회 연속 승리',
    ),
  ],
)
```

`requiredCount` 값은 밸런스 튜닝 대상이다. 문서의 숫자는 구조 예시이며, 최종 값은 stage catalog에서 관리한다.

## 9. UI 표시 기준

잠금 문구는 requirement의 `label`에서 파생한다.

예시:

- `잠금 조건: 1단계에서 실패 없이 3회 연속 승리`
- `진행도: 2/3 연속 승리`
- 실패 후: `진행도: 0/3 연속 승리`

이미 해금된 stage에는 조건 문구를 숨기거나 `해금 완료`로 표시한다.

## 10. 구현 영향 범위

예상 변경 범위는 아래와 같다.

- `ProgressState`
  - `unlockedStageIds`
  - `stageCurrentWinStreaks`
  - `stageBestWinStreaks`
- `BattleStageDefinition`
  - `unlockCondition` 단일 객체에서 `unlockRule` 또는 requirement list로 확장
- `BattleProgressionService`
  - encounter 결과 이벤트를 받아 streak 갱신
  - unlock rule 판정
- `BattleExpeditionProgressService`
  - encounter 종료 시 progression service에 성공 / 실패 이벤트 전달
- `DungeonScreen` selector
  - unlock rule label과 진행도 label 표시

## 11. 이전 구현과의 관계

이전 구현과 현재 구현의 차이는 아래와 같다.

- 이전: `clearedStageIds` 기반 이전 stage 클리어 해금
- 현재: 이전 stage 무실패 연속 승리 기반 영구 해금

기존 `BattleStageUnlockCondition.requiredStageId`는 유지하되, `requiredWinStreakCount`를 함께 사용해 `previousStageWinStreak` requirement 역할을 수행한다.

## 12. 완료 기준

- 다음 구현자가 재료 기반 해금을 다시 선택하지 않아야 한다.
- stage unlock의 1차 기준이 `이전 stage 무실패 연속 승리 N회`임을 문서만 보고 판단할 수 있어야 한다.
- 필요한 상태, 모델, UI 문구, 현재 구현과의 차이가 문서에 남아 있어야 한다.
