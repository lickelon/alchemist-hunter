# Workshop 양조 / 제작 분리 계획

## 1. 목적
- 현재 Workshop 제작 화면은 포션 제조만 다룬다.
- 티어업은 구현돼 있지만 승급 재료 획득 경로가 없어 실제 플레이에서는 막혀 있다.
- 따라서 포션은 `양조`로 분리하고, `제작`은 원소 + 재료를 통한 비포션 산출물 제작으로 확장한다.
- 첫 제작 대상은 승급 재료다.

## 2. 현재 구현 기준
- `WorkshopJobType.craft`는 현재 포션 제조 job으로만 사용된다.
- `WorkshopCraftEnqueueUseCase.enqueuePotion`은 추출 원소를 소비해 포션 job을 등록한다.
- `WorkshopQueueClaimService._claimCraftJob`은 완료된 craft job을 포션 스택으로만 수령한다.
- `Characters` 티어업은 `tier_mat_mercenary_N`, `tier_mat_homunculus_N` 재료를 소비하지만, 현재 정상 플레이 루프에서 해당 재료를 얻을 수 없다.

## 3. 확장 원칙
- 기존 포션 제조 흐름은 기능적으로 유지하되 명칭과 경계를 `양조`로 바꾼다.
- `양조`는 원소를 포션으로 변환하는 흐름이다.
- `제작`은 원소 + 재료 + 재화를 사용해 비포션 산출물을 만드는 흐름이다.
- `craft`라는 내부 이름은 점진적으로 정리한다. 사용자-facing 명칭은 `양조 / 제작`을 사용한다.
- 제작 결과는 재료 결과를 우선 지원하고, 이후 다른 산출물로 확장할 수 있어야 한다.
- 승급 재료는 완성품 직접 드롭보다 Workshop 제작으로 공급한다.
- 첫 구현은 T2 승급 재료만 연다. T3 이상은 stage / 밸런스 확장 이후 추가한다.

## 4. Town 제작과 Workshop 제작의 차이

### 4.1 Town 장비 제작
- 역할: 완성 장비를 만드는 물리 제작
- 주요 입력: 골드 + 재료
- 주요 산출물: 무기 / 방어구 / 장신구
- 효과: 캐릭터 전투력의 기본 골격을 직접 올린다.
- UX 기준: 대장간, 장비 슬롯, 스탯, 장착 가능 여부를 중심으로 보여준다.

### 4.2 Workshop 제작
- 역할: 연금 재료를 가공해 성장 매개체를 만드는 변환 제작
- 주요 입력: 원소 + 재료 + 정수 / 신비
- 주요 산출물: 승급 재료, 촉매, 특수 부품, 강화 매개체
- 효과: 직접 장비를 주기보다 캐릭터 성장, 강화, 해금의 병목을 푼다.
- UX 기준: 레시피, 조합, 변환, 원소 비용을 중심으로 보여준다.

### 4.3 경계 규칙
- 장착하는 물건은 Town에서 제작한다.
- 장착물이나 캐릭터 성장을 가능하게 하는 매개체는 Workshop에서 제작한다.
- 포션은 Workshop `양조`로 분리한다.
- 전투 보상 재료는 양쪽에서 쓰되, Town은 물리 재료 소비, Workshop은 원소화 / 변환 소비를 담당한다.

## 5. 1차 범위

### 5.1 양조 / 제작 명칭 분리
- 현재 포션 화면의 사용자-facing 명칭을 `포션 제조`에서 `양조`로 바꾼다.
- Workshop 대시보드에는 `양조`와 `제작`을 별도 진입점으로 둘 수 있게 한다.
- 1차 구현에서 화면을 반드시 물리적으로 둘로 나누지 않더라도, 문구와 모델 경계는 분리한다.

### 5.2 제작 레시피
새 제작 레시피 모델을 추가한다.

권장 모델:
- `WorkshopCraftRecipe`

권장 필드:
- `id`
- `name`
- `category`
- `materialCosts`
- `traitCosts`
- `essenceCost`
- `arcaneDustCost`
- `duration`
- `resultMaterials`

레시피 입력 규칙:
- 제작은 최소 하나 이상의 재료 비용을 가진다.
- 제작은 필요에 따라 원소 비용을 함께 가진다.
- 포션 양조처럼 원소만으로 완료되는 비포션 제작은 1차 범위에서 다루지 않는다.
- 승급 재료 제작은 일반 희귀 재료를 직접 핵심 비용으로 쓰지 않고, 전용 승급 촉매를 요구한다.

1차 레시피:
- `tier_mat_mercenary_2`
- `tier_mat_homunculus_2`

### 5.3 승급 재료 카탈로그
현재 코드가 요구하는 승급 재료 ID를 material catalog에 추가한다.

1차 입력 재료:
- `promo_core_mercenary_2`
- `promo_core_homunculus_2`

1차 추가 대상:
- `tier_mat_mercenary_2`
- `tier_mat_homunculus_2`

규칙:
- `analyzable: false`
- 전용 승급 촉매는 `source: battle_stage_2`
- 완성 승급 재료는 `source: workshop_craft`
- 추출 대상 목록에서는 제외한다.
- 인벤토리와 Characters 티어업 재료 표시는 가능해야 한다.

### 5.4 큐 job 결과 확장
`CraftQueueJob`에 재료 결과를 표현할 필드를 추가한다.

권장 필드:
- `completedMaterials: Map<String, int>`

기존 포션 결과 필드는 유지한다.
- `completedPotionStackKey`
- `completedPotion`

향후 정리 방향:
- 내부 enum은 현재 `WorkshopJobType.craft`를 유지할 수 있다.
- 이후 필요하면 `brew`와 `craft`를 분리한다.
- 1차 구현에서는 사용자-facing `양조 / 제작` 분리를 우선한다.

### 5.5 수령 처리
`WorkshopQueueClaimService._claimCraftJob`을 확장한다.

수령 규칙:
- 포션 결과가 있으면 기존처럼 `craftedPotionStacks`에 반영한다.
- 재료 결과가 있으면 `player.materialInventory`에 반영한다.
- 둘 다 없으면 상태를 변경하지 않는다.

### 5.6 등록 use case
기존 `enqueuePotion`은 유지한다.

새 등록 경로:
- `enqueueMaterialRecipe`

역할:
- 레시피 존재 확인
- 재료 / 원소 / 정수 / 신비 비용 확인
- 비용 선차감
- `WorkshopJobType.craft` job 등록
- 완료 결과로 `completedMaterials` 설정

### 5.7 UI
현재 `WorkshopCraftSheet`는 포션 목록만 보여준다.

변경 기준:
- 포션 진입점은 `양조`로 명명한다.
- 승급 재료 진입점은 `제작`으로 명명한다.
- `양조`와 `제작`은 같은 작업 큐를 사용한다.
- 화면을 합칠 경우에도 섹션 제목은 `양조 / 제작`으로 분리한다.

승급 재료 섹션 표시:
- 아이콘
- 이름
- 비용 요약
- 제작 가능 여부
- 등록 버튼

## 6. 제외 범위
- T3 이상 승급 재료
- 조각 드롭 / 조각 합성 구조
- 다이아 기반 슬롯 확장
- 저장 / 오프라인 복원
- 전역 인벤토리 시스템 신설

## 7. 검증 기준
- 기존 포션 제조 등록 / 완료 수령이 깨지지 않아야 한다.
- 승급 재료 제작 등록 시 비용이 선차감되어야 한다.
- 승급 재료 제작 완료 수령 시 `materialInventory`에 완성 재료가 추가되어야 한다.
- Characters 티어업은 기존 로직을 그대로 사용해야 한다.
- `flutter analyze`를 통과해야 한다.

## 8. 권장 작업 순서
1. 포션 제조 명칭을 `양조`로 분리하고, 제작 계획 문구와 UI 경계를 정리
2. 승급 재료와 제작 레시피 모델 / 카탈로그 추가
3. craft job 결과 재료 필드와 수령 처리 확장
4. 승급 재료 제작 등록 use case / controller 추가
5. Workshop에 `제작` 진입점 또는 제작 섹션 추가
6. 최소 테스트와 analyze 확인
