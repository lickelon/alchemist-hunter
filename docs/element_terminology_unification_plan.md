# Element 용어 통일 방안

## 1. 목적

작업실 추출 자원과 포션 조성에 섞여 있는 `trait / 특성 / element` 표현을 `element / 원소`로 통일한다.

이번 정리는 먼저 사용자 노출 용어와 현재 기준 문서를 맞추는 것이 목적이다. 내부 저장 구조와 도메인 식별자 변경은 별도 리팩토링으로 분리한다.

## 2. 공식 용어

| 구분 | 사용할 용어 | 설명 |
| --- | --- | --- |
| 영문 | `Element` | 재료에서 추출되는 작업실 제작 단위 |
| 한글 | `원소` | UI와 문서에서 사용하는 기본 표기 |
| 보조 표현 | `추출 원소` | 재료 추출로 얻은 원소임을 강조해야 할 때 사용 |

## 2.1 관련 재화 용어

| 영문 | 한글 | 설명 |
| --- | --- | --- |
| `Essence` | `정수` | 전투 보상으로 획득하고 작업실 부화 등에 사용하는 재화 |
| `Fame` | `명성` | 포션 판매 등으로 획득하고 마을 성장에 사용하는 재화 |
| `Arcane` | `신비` | 재료 추출 완료 보상으로 획득하고 작업실 성장에 사용하는 재화 |

`정수`는 재화 이름으로만 사용한다. 코드의 정수형 값이나 일반 수량 설명과 구분하기 위해 문서에서 타입을 말할 때는 `int`, `정수형`, `수치`처럼 표현한다.
기존 `TownInsight` 또는 `TownSight` 계열 명칭은 더 이상 사용하지 않고 `Fame / 명성`으로 교체한다.
기존 `ArcaneDust`는 더 이상 사용자 노출 용어로 쓰지 않고 `Arcane / 신비`로 줄인다. UI 기본 표기는 `신비`다. 자원 성격을 설명해야 하는 문서 문맥에서는 `신비 가루`를 보조 표현으로 사용할 수 있다.

## 3. 더 이상 쓰지 않을 표현

| 기존 표현 | 변경 후 |
| --- | --- |
| `Trait / Element` | `Element` |
| `Element / Trait` | `Element` |
| `trait 재고` | `원소 재고` |
| `추출 trait` | `추출 원소` |
| `추출 특성` | `추출 원소` |
| `특성 정보 없음` | `원소 정보 없음` |
| `특성 부족` | `원소 부족` |
| `특성 재료 부족` | `원소 부족` |
| `TownInsight` | `Fame` |
| `TownSight` | `Fame` |
| `townsight` | `fame` |
| `마을 인사이트` | `명성` |
| `ArcaneDust` | `Arcane` |
| `Arcane Dust` | `Arcane` |
| `아케인 더스트` | `신비` |
| `비전` | `신비` |

## 4. 의미 경계

`원소`는 작업실의 제작 자원이다.

- 재료 분석 결과로 표시된다.
- 재료 추출을 통해 재고로 적재된다.
- 포션 제조의 목표 조성으로 사용된다.
- 작업실 스킬트리 일부 비용으로 사용된다.
- 호문쿨루스 부화 비용으로 사용된다.
- 장비 인챈트에서 포션 조성의 기준값으로 사용된다.

`원소`가 아닌 것은 아래처럼 분리한다.

| 개념 | 사용할 용어 | 예시 |
| --- | --- | --- |
| 캐릭터 고유 능력 | `패시브` | 필중, 2회 공격, 흡혈 |
| 전투 계산 보정 | `전투 효과`, `modifier` | 주는 피해 증가, 받는 피해 감소 |
| 분류용 표식 | `태그` | 비행, 언데드, 정예 |
| 전투 상성 속성 | `속성` | 화염, 냉기, 번개 |

따라서 전투 문서에서 `적 특성`처럼 쓰인 표현은 원소가 아니라 `적 패시브` 또는 `적 전투 효과`로 바꿔야 한다.

## 5. 현재 구현 기준

현재 코드는 내부적으로 아직 `trait` 계열 식별자를 넓게 사용한다.

- `TraitUnit`
- `TraitType`
- `traitCatalog`
- `extractedTraitInventory`
- `PotionBlueprint.targetTraits`
- `CraftedPotion.traits`
- `HomunculusHatchRecipe.traitCosts`
- `completedExtractedTraits`

반면 작업실 스킬트리 비용 타입에는 이미 `WorkshopSkillCostType.element`가 존재한다. 즉 현재 구현은 내부 이름은 `trait`, 일부 비용 타입은 `element`, UI와 문서는 `특성`이 섞인 상태다.

## 6. 적용 순서

### 6.1 1단계: 노출 용어 정리

우선 사용자에게 보이는 문자열과 현재 기준 문서를 정리한다.

- 작업실 인벤토리 탭: `특성` -> `원소`
- 추출 시트: `보유 추출 특성` -> `보유 추출 원소`
- 빈 상태: `추출된 특성이 없습니다` -> `추출된 원소가 없습니다`
- 포션 상세: `특성 Aggro 70%` -> `원소 Aggro 70%`
- 제조 불가 사유: `추출 특성 부족` -> `추출 원소 부족`
- 스킬트리 비용: `Vital 특성 1` -> `Vital 원소 1`
- 부화 비용 부족: `특성 재료 부족` -> `원소 부족`
- 현재 기준 문서: `Trait / Element`, `trait 비용`, `trait 재고` 표현 제거
- 관련 위젯 테스트 기대 문자열 갱신

### 6.2 2단계: 문서와 테스트 설명 정리

테스트명과 테스트 목록 문서에서 기능 설명 용어를 `원소`로 맞춘다.

- `stores extracted traits` -> `stores extracted elements`
- `dominant trait` -> `dominant element`
- `compound trait` -> `compound element`
- `trait stock` -> `element stock`

단, 코드 식별자를 그대로 설명해야 하는 경우에는 백틱으로 감싼다.

예시:

- 현재 구현 필드명은 `extractedTraitInventory`다.
- 사용자 개념명은 `원소 재고`다.

### 6.3 3단계: 내부 식별자 리팩토링 검토

내부 식별자 변경은 저장 정책과 데이터 구조가 안정된 뒤 진행한다.

후보 변경은 아래와 같다.

| 현재 | 후보 |
| --- | --- |
| `TraitUnit` | `ElementUnit` |
| `TraitType` | `ElementType` |
| `traitCatalog` | `elementCatalog` |
| `traitsProvider` | `elementsProvider` |
| `extractedTraitInventory` | `extractedElementInventory` |
| `targetTraits` | `targetElements` |
| `CraftedPotion.traits` | `CraftedPotion.elements` |
| `traitCosts` | `elementCosts` |
| `completedExtractedTraits` | `completedExtractedElements` |

이 단계는 상태 스냅샷, 테스트 픽스처, 큐 job 모델, 포션 모델, 부화 모델을 동시에 건드리므로 1단계와 섞지 않는다.

## 7. 1차 적용 범위

바로 진행할 수 있는 범위는 아래로 제한한다.

- `lib/features/workshop/**`의 사용자 노출 문자열
- 관련 위젯 테스트의 기대 문자열
- `docs/development_plan_v3.md`
- `docs/test_inventory.md`
- `docs/character_sheet_issues.md`
- `Essence`의 사용자 노출 한글명은 `에센스`가 아니라 `정수`로 정리
- 전투 문서에서 원소가 아닌 `특성` 표현은 `패시브` 또는 `전투 효과`로 정리

이번 단계에서는 아래를 하지 않는다.

- 저장 필드명 변경
- 도메인 클래스명 변경
- 카탈로그 ID 변경
- 기존 `t_hp`, `t_atk` 같은 원소 ID 변경
- v1, v2 같은 과거 계획 문서 전면 정리

## 8. 검수 기준

1단계 완료 후 아래 조건을 만족해야 한다.

- 현재 UI에서 작업실 추출 자원을 `특성`으로 부르지 않는다.
- 현재 기준 문서에서 `Trait / Element`, `Element / Trait` 혼용이 사라진다.
- 포션 조성, 추출 재고, 스킬트리 비용, 부화 비용 설명은 모두 `원소`를 사용한다.
- 전투의 특수 능력은 `원소`가 아니라 `패시브` 또는 `전투 효과`로 표현한다.
- 내부 코드 식별자로 남은 `trait`는 별도 리팩토링 대상으로 문서화되어 있다.
