# 현재 테스트 인벤토리

## 1. 문서 목적
- 이 문서는 현재 저장소에 존재하는 테스트를 영역별로 정리한 목록이다.
- 기준은 `test/` 아래 실제 파일과 현재 등록된 테스트 케이스 제목이다.
- 커버리지 퍼센트나 CI 상태를 기록하는 문서는 아니다.

## 2. 현재 규모
- 기준 시점: 2026-05-14
- 테스트 파일: 47개
- 테스트 케이스: 128개

## 3. 영역별 분포

| 영역 | 파일 수 | 케이스 수 | 현재 커버 초점 |
| --- | ---: | ---: | --- |
| `app` | 1 | 3 | 세션 sync와 시간 가속 |
| `architecture` | 1 | 1 | import 경계 유지 |
| `core` | 1 | 2 | 세션 상태 적용과 로그 처리 |
| `features/battle` | 9 | 40 | 전투 계산, 해금, 자동전투, 편성 UI |
| `features/characters` | 4 | 11 | 장비 장착, 승급, 힌트/상세 시트 |
| `features/town` | 10 | 23 | 상점, 장비 제작, 용병 고용, 마을 스킬트리 |
| `features/workshop` | 20 | 47 | 큐, 추출, 포션, 인챈트, 부화, 작업실 스킬트리 |
| `root` | 1 | 1 | 최상위 탭 노출 smoke test |

## 4. 상세 목록

### 4.1 App / Architecture / Core

#### `test/app/session/session_progress_sync_use_case_test.dart`
- 세션 sync가 시간 가속을 반영해서 전투 `탐색 -> 전투 -> 다음 탐색` 진행과 대장간 진행을 실제로 앞당기는지 검증한다.
- 포션이 부족한 경우 현재 교전이 `loadout fallback` 상태로 시작되는지 검증한다.
- battle/workshop/town 진행이 `SessionProgressSyncUseCase` 경계에서 함께 맞물리는지 보는 통합 성격 테스트다.

#### `test/architecture/import_boundary_test.dart`
- `core`, `domain`, `presentation` 레이어가 허용되지 않은 import를 하지 않는지 확인한다.
- 구조 문서에서 정한 경계가 코드 차원에서 깨지지 않도록 막는 테스트다.

#### `test/core/session/session_controller_test.dart`
- `applyState`가 feature 로직 없이 세션 스냅샷만 교체하는지 확인한다.
- 같은 로그가 연속으로 들어올 때 중복 추가를 막는지 확인한다.

### 4.2 Battle

#### `test/features/battle/domain/services/battle_party_power_service_test.dart`
- 장비 기본 스탯이 파티 전투력 합산에 반영되는지 검증한다.
- 장비 특수효과가 `HeroProfile`의 전투용 데이터에 실리는지 확인한다.
- 레벨업이 HP만 올리고 비HP 기본 스탯은 유지하는지 확인한다.
- `jobId`가 바뀌면 전투 스탯 프로필도 달라지는지 확인한다.

#### `test/features/battle/domain/services/battle_progression_service_test.dart`
- stage 해금 판정이 `unlockFlags`가 아니라 이전 stage의 최고 연속 승리 수를 기준으로 동작하는지 확인한다.
- stage 성공 encounter가 현재/최고 연속 승리 수, `clearedStageIds`, 비stage 해금 flag를 갱신하는지 확인한다.

#### `test/features/battle/domain/services/battle_expedition_progress_service_test.dart`
- 성공 encounter 이후 아군 HP가 다음 탐색까지 유지되는지 확인한다.
- 탐색 회복이 살아있는 아군에게만 적용되고 사망 아군은 사망 상태로 유지되는지 검증한다.
- 전멸 시 `recovering`으로 전환되고 기존 pending claim이 유지되는지 확인한다.
- recovery 완료 후 아군이 풀 HP로 초기화되는지 검증한다.
- 성공 encounter XP가 즉시 반영되고 수령 시 중복 반영되지 않는지 확인한다.
- 포션 부족 fallback이 현재 encounter와 최근 로그에 남는지 검증한다.

#### `test/features/battle/domain/services/battle_service_test.dart`
- `HeroProfile`의 MP와 스킬 정의가 run unit 상태로 전달되는지 검증한다.
- `power`가 0이어도 실제 전투 스탯만으로 승패가 계산되는지 검증한다.
- 과거처럼 높은 전투력 숫자만으로 자동 승리하지 않는지 확인한다.
- 추가 공격 패시브가 추가 공격을 재귀적으로 다시 생성하지 않는지 확인한다.
- 반격 패시브가 행동 큐를 변경하지 않고 파생 lifecycle로 실행되는지 확인한다.
- 선공 패시브가 encounter 첫 행동 순서에만 적용되는지 확인한다.
- `grantModifier` 패시브가 대상에게 임시 modifier를 부여하고 소유자 turn end에서 만료되는지 확인한다.
- 상태이상 패시브가 독 피해를 적용하고 turn end에서 만료되는지 확인한다.
- 보호막 패시브가 HP 피해보다 먼저 피해를 흡수하는지 확인한다.
- 필중 패시브가 `beforeHitCheck` 훅에서만 적용되는지 확인한다.
- 일반 공격 lifecycle 이후 정수 `MP재생`만큼 MP가 회복되는지 확인한다.
- 현재 MP가 최대 MP에 도달하면 액티브 스킬을 사용하고 MP를 전부 소비하는지 확인한다.

#### `test/features/battle/domain/use_cases/battle_expedition_use_case_test.dart`
- 실패한 무보상 전투를 수령해도 다음 stage 해금이 열리지 않는지 검증한다.
- `hasSuccessfulBattle` 기반 수령 판정이 실제 progression에 반영되는지 보는 보호 테스트다.

#### `test/features/battle/domain/use_cases/configure_battle_assignment_use_case_test.dart`
- 편성 토글이 같은 캐릭터를 추가/제거로 정확히 반전시키는지 확인한다.

#### `test/features/battle/presentation/dungeon_screen_test.dart`
- 잠긴 stage의 잠금 사유 문구가 화면에 보이는지 검증한다.
- 연속 run 기준 전투 현황 시트, 적 조합/드롭 시트, 최근 기록 시트까지 실제 UI 진입 흐름을 확인한다.
- 최근 기록 시트에서 encounter 이름, 재료명, 행동 로그가 올바르게 보이는지 확인한다.

#### `test/features/battle/presentation/viewmodels/battle_controller_test.dart`
- 즉시 전투 후 골드, 정수, 재료, 즉시 XP, 최근 로그가 함께 갱신되는지 검증한다.
- 랭크 최대 레벨 구간에서 XP overflow가 나지 않는지 확인한다.
- 장비 스탯 강화 후 Stage 5 클리어 가능성이 실제로 올라가는지 확인한다.
- stage별 포션 loadout이 있으면 즉시 전투에서 실제로 소비되는지 검증한다.
- 포션이 부족하면 전투는 계속 진행하되 recent log에 fallback 사유가 남는지 확인한다.
- battle 편성 저장과 workshop 배치 충돌 차단을 함께 검증한다.

#### `test/features/battle/presentation/widgets/battle_assignment_sheet_test.dart`
- 편성 시트에서 캐릭터 선택 토글이 실제 stage 배치 상태에 반영되는지 확인한다.
- 편성 시트에서 포션 수량 증감이 `stagePotionLoadouts`에 저장되는지 검증한다.

### 4.3 Characters

#### `test/features/characters/domain/use_cases/character_equipment_use_case_test.dart`
- 장비 장착 시 보관함 장비가 슬롯으로 이동하는지 확인한다.
- 기존 장착 장비가 있을 경우 보관함으로 되돌아가는지 검증한다.
- 해제 시 장비가 다시 storage로 복귀하는지 확인한다.

#### `test/features/characters/presentation/characters_screen_test.dart`
- 캐릭터 목록/상세에서 랭크업, 티어업 힌트가 보이는지 검증한다.
- 호문쿨루스 origin, role, support 효과가 화면에 노출되는지 확인한다.

#### `test/features/characters/presentation/viewmodels/character_controller_test.dart`
- 랭크업 시 레벨/XP 초기화와 rank 증가가 함께 일어나는지 확인한다.
- 티어업 시 재료를 소비하고 tier가 상승하는지 검증한다.
- 최대 레벨에서는 다음 레벨 필요 XP가 0으로 처리되는지 확인한다.
- 장비 장착/해제가 세션 상태에 올바르게 반영되는지 확인한다.

#### `test/features/characters/presentation/viewmodels/character_selectors_test.dart`
- 랭크업/티어업 조건 힌트 selector가 현재 성장 상태를 정확히 표현하는지 검증한다.
- 호문쿨루스 상세용 라벨이 origin, role, support 문구를 정확히 뽑는지 확인한다.

### 4.4 Town

#### `test/features/town/data/static_town_skill_tree_repository_test.dart`
- 마을 스킬트리 repository가 루트 노드와 전체 노드를 정상 노출하는지 확인한다.

#### `test/features/town/domain/services/economy_service_test.dart`
- 강제 새로고침 비용이 같은 주기 안에서 상승하는지 검증한다.
- 자동 새로고침이 되면 비용과 카운트가 초기화되는지 확인한다.

#### `test/features/town/domain/use_cases/upgrade_town_skill_node_use_case_test.dart`
- 루트 스킬 업그레이드가 `TownInsight`를 소비하고 레벨을 올리는지 확인한다.
- 일반 노드 업그레이드가 다음 레벨 비용의 `Gold`를 소비하는지 검증한다.

#### `test/features/town/presentation/viewmodels/town_controller_test.dart`
- 일반 상점 재료 구매 시 골드, 인벤토리, 상점 수량이 함께 갱신되는지 확인한다.
- 강제 새로고침이 골드를 소비하고 상점 구성을 바꾸는지 검증한다.
- 마을 스킬 할인 효과가 새로고침과 용병 고용에 실제로 반영되는지 확인한다.
- 장비 제작 예약이 재료를 잡고 대장간 큐에 들어가는지 검증한다.
- 대장간 재료 절감 효과가 실제 제작 예약 비용에 반영되는지 확인한다.
- 용병 고용 시 골드 소비, roster 추가, 후보 새로고침이 올바르게 동작하는지 검증한다.

#### `test/features/town/presentation/viewmodels/town_potion_sale_controller_test.dart`
- 제작 포션 판매 시 stack이 제거되고 골드가 증가하는지 확인한다.
- 판매 보너스가 있을 때 추가 골드가 반영되는지 검증한다.

#### `test/features/town/presentation/viewmodels/town_selectors_test.dart`
- 마을 스킬 selector가 통찰 수치와 노드 진행도를 올바르게 노출하는지 확인한다.

#### `test/features/town/presentation/widgets/town_equipment_card_test.dart`
- 장비 카드/시트가 제작 가능한 blueprint 목록을 보여주는지 확인한다.
- 시트에서 바로 제작 예약이 가능한지 검증한다.

#### `test/features/town/presentation/widgets/town_mercenary_card_test.dart`
- 용병 카드/시트가 현재 고용 후보를 보여주는지 확인한다.
- 시트에서 고용하면 세션 상태가 갱신되는지 검증한다.

#### `test/features/town/presentation/widgets/town_potion_sale_sheet_test.dart`
- 포션 판매 시트가 내부 stack key가 아니라 사용자용 포션 이름을 보여주는지 확인한다.

#### `test/features/town/presentation/widgets/town_skill_tree_sheet_test.dart`
- 스킬트리 시트에서 루트 노드 업그레이드가 실제로 가능한지 검증한다.

### 4.5 Workshop

#### `test/features/workshop/craft_queue/domain/services/craft_queue_service_test.dart`
- 제작 큐 tick이 랜덤 실패 없이 완료 상태로 정상 전이되는지 확인한다.

#### `test/features/workshop/craft_queue/presentation/viewmodels/craft_queue_controller_test.dart`
- 포션 제작 enqueue 시 추출 trait이 예약되고 job이 생성되는지 검증한다.
- 포션/추출 완료 보상을 선택한 job에만 적용하는지 확인한다.
- 큐가 가득 찬 경우 enqueue가 차단되는지 검증한다.
- 포션 queue 옵션 selector가 unlock flag와 재고 수량을 함께 반영하는지 확인한다.

#### `test/features/workshop/craft_queue/presentation/widgets/workshop_queue_sheet_test.dart`
- 큐 시트가 진행 중 job과 완료된 job을 한 목록에서 보여주는지 확인한다.

#### `test/features/workshop/crafting/domain/services/potion_crafting_service_test.dart`
- dominant trait 비율에 따라 포션 타입이 갈리는지 검증한다.
- 목표 비율 점수에 따라 품질 등급이 계산되는지 확인한다.
- 제작 준비 시 필요한 trait만 정확히 소비하는지 검증한다.
- 반복 제작용 trait 요구량 집계가 올바른지 확인한다.

#### `test/features/workshop/crafting/presentation/widgets/workshop_craft_sheet_test.dart`
- 포션 제작 시트가 등록 가능한 포션 옵션을 보여주는지 확인한다.
- 큐가 가득 찼을 때 경고를 헤더에 한 번만 보여주는지 검증한다.
- 큐가 가득 찼을 때 toast가 뜨는지 확인한다.

#### `test/features/workshop/dashboard/presentation/screens/workshop_screen_test.dart`
- 작업실 메인 화면이 큐와 인벤토리 카드를 우선 배치하는지 검증한다.

#### `test/features/workshop/dashboard/presentation/viewmodels/workshop_shared_selectors_test.dart`
- 작업실 공용 selector가 `ArcaneDust`와 스킬트리 진행도를 올바르게 노출하는지 확인한다.

#### `test/features/workshop/enchanting/domain/services/equipment_enchant_service_test.dart`
- 무기 인챈트가 dominant trait 기준으로 공격 중심 옵션을 더 강하게 주는지 검증한다.

#### `test/features/workshop/enchanting/domain/use_cases/workshop_enchant_use_case_test.dart`
- 보관함 장비와 장착 중 장비 모두 인챈트 예약이 가능한지 확인한다.
- 인챈트 potency 보너스가 스킬트리/지원 보조 효과를 반영하는지 검증한다.

#### `test/features/workshop/enchanting/presentation/widgets/workshop_enchant_sheet_test.dart`
- 인챈트 시트에서 실제 queue enqueue가 되는지 확인한다.
- 기존 옵션 덮어쓰기 전에 확인 절차가 있는지 검증한다.
- 큐가 가득 찼을 때 toast가 뜨는지 확인한다.

#### `test/features/workshop/extraction/domain/services/alchemy_service_test.dart`
- compound trait 분해가 단일 trait로 풀리는지 검증한다.
- trait 합성이 새로운 compound trait를 만드는지 확인한다.
- 추출 인벤토리 flatten이 compound를 단일 trait 재고로 환산하는지 검증한다.

#### `test/features/workshop/extraction/presentation/viewmodels/extraction_controller_test.dart`
- 재료 추출 시 재료 소비와 trait 적재가 함께 일어나는지 확인한다.
- bulk 추출, 추출량 보너스, 지원 보조 보너스가 실제 수치에 반영되는지 검증한다.
- 큐가 가득 찼을 때 `queueFull` 응답을 반환하는지 확인한다.

#### `test/features/workshop/hatchery/domain/use_cases/workshop_hatch_use_case_test.dart`
- 호문쿨루스 부화 예약이 자원과 재료를 잡고 job을 생성하는지 검증한다.
- 부화 슬롯 관련 arcane dust 할인 효과가 실제로 적용되는지 확인한다.

#### `test/features/workshop/hatchery/presentation/widgets/workshop_hatch_sheet_test.dart`
- 부화 시트에서 enqueue가 가능한지 확인한다.
- 큐가 가득 찼을 때 toast가 뜨는지 검증한다.

#### `test/features/workshop/inventory/presentation/widgets/workshop_inventory_sheets_test.dart`
- 인벤토리 시트가 재료, trait, 포션을 각각 표시하는지 확인한다.
- 추출 시트가 trait 재고와 추출 액션을 보여주는지 검증한다.
- 추출 상세에서 큐 포화 시 toast가 뜨는지 확인한다.

#### `test/features/workshop/skill_tree/data/static_workshop_skill_tree_repository_test.dart`
- 작업실 스킬트리 repository가 루트와 전체 노드를 정상 노출하는지 확인한다.

#### `test/features/workshop/skill_tree/domain/use_cases/upgrade_workshop_skill_node_use_case_test.dart`
- 루트 업그레이드가 `ArcaneDust`를 소비하는지 확인한다.
- 일반 노드 업그레이드가 `Element` 비용을 소비하는지 검증한다.

#### `test/features/workshop/skill_tree/presentation/widgets/workshop_skill_tree_sheet_test.dart`
- 작업실 스킬트리 시트에서 루트 노드 업그레이드가 실제로 가능한지 확인한다.

#### `test/features/workshop/support/domain/use_cases/configure_workshop_support_assignment_use_case_test.dart`
- 지원 슬롯 배정/해제가 정상 동작하는지 검증한다.
- 이미 다른 슬롯에 있는 호문쿨루스를 바로 재배치하지 못하게 막는지 확인한다.
- 용병 배치 차단과 총 지원 슬롯 상한 3개가 유지되는지 검증한다.

#### `test/features/workshop/support/presentation/widgets/workshop_support_sheet_test.dart`
- 지원 시트에서 호문쿨루스를 추출 슬롯에 배정할 수 있는지 확인한다.

### 4.6 Root Smoke

#### `test/widget_test.dart`
- 앱 진입 시 4개 메인 탭이 기본적으로 보이는지 확인하는 smoke test다.

## 5. 현재 해석
- `workshop` 테스트가 가장 두껍다. 제작 큐, 추출, 인챈트, 부화, 스킬트리, 지원 배치까지 끊어 검증하고 있다.
- `battle`은 최근 리팩토링 이후 전투 계산, 해금, 포션 loadout/fallback, 전투 UI까지 핵심 경로 보호 테스트가 들어가 있다.
- `battle`은 최근 연속 run 전투 전환 이후 탐색, 교전 시작, 즉시 전투, 최근 기록 시트까지 핵심 경로 보호 테스트가 들어가 있다.
- `town`은 상점 경제, 장비 제작, 용병 고용, 스킬트리 쪽 흐름이 비교적 잘 커버돼 있다.
- `characters`는 장비 장착/해제와 성장 규칙 위주다. 캐릭터 상세 시트의 세부 표현 검증은 아직 얇은 편이다.
- 전역적으로는 저장/복원, 오프라인 복구, 경제 밸런스 회귀, 대규모 데이터 회귀 테스트는 아직 부족하다.
