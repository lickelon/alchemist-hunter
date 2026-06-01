# 밸런스 데이터 외부화 사전 정리

## 1. 목적
가격, 드롭, 제작 시간, 보상, 승급 재료처럼 자주 조정될 데이터를 코드에서 분리하기 위한 사전 정리 문서다.

현재 단계에서는 실제 JSON 로딩이나 원격 설정을 도입하지 않는다. 먼저 어떤 데이터가 밸런스 데이터인지, 어떤 순서로 외부화할지 정한다.

## 2. 외부화 대상 원칙
외부화 대상은 다음 조건을 만족하는 데이터다.

- 플레이 중 수급량, 소비량, 시간, 난이도에 직접 영향을 준다.
- 기획 조정이 잦다.
- 코드 로직보다 테이블 수정으로 다루는 편이 안전하다.
- 저장 데이터가 참조할 수 있으므로 ID 안정성이 중요하다.

반대로 아래 항목은 당장 외부화하지 않는다.

- 도메인 모델 타입
- combat action lifecycle
- sync 순서
- UI layout
- feature 경계
- 저장 DTO 구조

## 3. 현재 밸런스 데이터 위치

| 영역 | 현재 파일 | 주요 데이터 |
| --- | --- | --- |
| Battle stage | `lib/features/battle/data/catalogs/battle_stage_definitions.dart` | 권장 전투력, 탐색 시간, 복구 시간, 보상, 해금 조건 |
| Battle enemy | `lib/features/battle/data/catalogs/enemies/*` | 적 스탯, 액티브 스킬, 패시브, 적별 드롭 |
| Battle encounter | `lib/features/battle/data/catalogs/encounters/*` | stage별 적 조합, 조합 확률 |
| Town shop | `lib/features/town/data/catalogs/shop_seed.dart` | 상점 재료, 가격, 수량, 갱신 시간, 강제 갱신 비용 |
| Equipment blueprint | `lib/features/town/data/catalogs/equipment_blueprints.dart` | 장비 제작 재료, 기본 스탯, 특수 효과 |
| Mercenary template | `lib/features/town/data/catalogs/mercenary_templates.dart` | 용병 후보 기본값, 고용 비용 |
| Town skill tree | `lib/features/town/data/catalogs/town_skill_nodes.dart` | 스킬 비용, 선행 조건, 효과량 |
| Material catalog | `lib/features/workshop/extraction/data/catalogs/material_catalog.dart` | 재료 이름, 희귀도, 원소 구성 |
| Extraction profile | `lib/features/workshop/extraction/data/catalogs/extraction_profiles.dart` | 추출 수율, 순도, 소요 시간 |
| Potion catalog | `lib/features/workshop/crafting/data/catalogs/potion_catalog.dart` | 포션 양조 레시피, 품질 규칙, 분기 규칙, 기본 판매가 |
| Workshop craft recipe | 계획: `lib/features/workshop/crafting/data/catalogs/workshop_craft_recipes.dart` | 원소 + 재료 기반 비포션 제작 레시피, 승급 재료 제작 비용, 제작 시간 |
| Hatch recipe | `lib/features/workshop/hatchery/data/catalogs/homunculus_hatch_recipes.dart` | 부화 비용, 결과 호문쿨루스, 소요 시간 |
| Workshop skill tree | `lib/features/workshop/skill_tree/data/catalogs/workshop_skill_nodes.dart` | 스킬 비용, 선행 조건, 효과량 |

## 4. 외부화 우선순위

### 1차: Battle stage / enemy / encounter
완료됐다. `assets/data/battle_catalog.json`에서 로딩한다.

이유는 다음과 같다.

- 스테이지 난이도와 보상이 가장 자주 조정된다.
- enemy, encounter, stage 보상이 서로 강하게 연결되어 있다.
- 저장 정책에서 `contentVersion`과 직접 연결되는 대표 데이터다.

포함 범위는 다음과 같다.

- stage 권장 전투력
- 탐색 / 복구 시간
- 성공 보상
- XP
- 해금 조건
- 적 스탯
- 적별 드롭
- encounter 조합과 확률

### 2차: Town / Workshop 경제 테이블
완료됐다. Town은 `assets/data/town_catalog.json`, Workshop은 `assets/data/workshop_catalog.json`에서 로딩한다.

포함 범위는 다음과 같다.

- 상점 가격과 수량
- 상점 갱신 시간과 강제 갱신 비용
- 장비 제작 재료와 장비 기본 스탯
- 포션 양조 레시피와 기본 판매가
- 원소 + 재료 기반 제작 레시피
- 추출 프로필 수율, 순도, 시간
- 부화 비용과 시간

### 3차: 스킬트리 테이블
완료됐다. Town / Workshop 스킬트리는 각 feature catalog JSON에 포함한다.

포함 범위는 다음과 같다.

- 노드 ID
- 노드 이름과 설명
- 선행 조건
- 비용
- 효과 타입과 효과량
- 최대 레벨

### 4차: 캐릭터 / 용병 템플릿
용병 템플릿은 완료됐다. `assets/data/town_catalog.json`에 포함한다.

캐릭터 성장 테이블은 아직 코드에 남긴다. 저장 데이터에 직접 남는 개체이므로, 템플릿 변경이 기존 캐릭터에 미치는 영향을 먼저 정의해야 한다.

포함 범위는 다음과 같다.

- 용병 후보 기본 이름
- 고용 비용
- 기본 combat job
- 초기 성장값

## 5. 외부화하지 않을 값
아래 값은 현재 코드에 남긴다.

- sync cap 8시간
- battle action interval 1초
- feature별 상태 소유권
- 저장/복원 정책
- 전투 action lifecycle 단계
- UI 표시 순서

이 값들은 밸런스보다 시스템 규칙에 가깝다. 조정이 필요하면 별도 설계 변경으로 다룬다.

## 6. 데이터 형식 원칙
외부화할 때는 JSON 또는 Dart data file 중 하나를 선택한다.

현재 권장 순서는 다음과 같다.

1. 먼저 현재 Dart catalog 구조를 유지하되 파일을 더 작게 분리한다.
2. ID와 필드 구조가 안정화되면 JSON schema를 정의한다.
3. JSON 로딩은 validation을 먼저 붙인 뒤 도입한다.

초기에는 원격 설정을 사용하지 않는다. 로컬 asset 기반 로딩만 검토한다.

## 7. 검증 기준
외부화가 시작되면 각 테이블은 최소 검증을 가져야 한다.

- ID 중복 없음
- 참조 ID 존재
- 확률 합계 유효
- 비용이 음수가 아님
- 시간 값이 0보다 큼
- stage가 최소 1개 encounter를 가짐
- enemy가 유효한 stat과 drop을 가짐

## 8. 현재 결론
Battle stage / enemy / encounter 카탈로그는 `assets/data/battle_catalog.json` 로컬 asset에서 읽고, `data/catalogs`의 DTO 파서를 거쳐 도메인 모델로 변환한다.

Town 카탈로그는 `assets/data/town_catalog.json` 로컬 asset에서 읽는다. 포함 범위는 상점 가격 / 수량 / 갱신 시간, 장비 제작, 용병 템플릿, Town 스킬트리다.

Workshop 카탈로그는 `assets/data/workshop_catalog.json` 로컬 asset에서 읽는다. 포함 범위는 재료 / 원소, 추출 프로필, 포션 양조 레시피, 원소 + 재료 제작 레시피, 부화 레시피, Workshop 스킬트리다.

기존 Dart catalog 상수는 테스트와 fallback 용도로 남겨두며, 앱 런타임의 기준 데이터는 로컬 JSON asset이다.
