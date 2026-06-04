# UI 폴리싱 계획

## 1. 목적
기능 추가보다 현재 화면의 완성도를 높이는 작업 순서를 정리한다.

이 문서는 새 디자인 시스템을 다시 정의하지 않는다. 기준은 아래 문서를 따른다.

- [UI 디자인 시스템 기준](./ui_design_system_guidelines.md)
- [UI 디자인 갭 정리](./ui_design_gaps.md)
- [UI/UX 검토 보고서](./ui_ux_review.md)

## 2. 폴리싱 원칙
- 기능 의미를 바꾸지 않는다.
- 저장, 밸런스, 신규 성장 루프는 이 범위에 넣지 않는다.
- 화면별로 공통 컴포넌트 사용 여부를 먼저 확인한다.
- 한 화면에서 반복 노출되는 중복 정보부터 줄인다.
- 모달, 바텀시트, 그리드, 빈 상태는 공통 규칙을 우선 적용한다.
- 테스트로 디자인 금지 규칙을 강제하지 않는다.

## 3. 실제 코드 기준 우선순위

### 3.1 공통 UI 컴포넌트 폴리싱
목표는 feature 폴리싱 전에 공통 위젯의 시각 규칙과 기본 동작을 정리하는 것이다.

상위 확인 항목:
- `AppSheetLayout` footer 사용 여부
- `AppDialogLayout` actions 사용 여부
- 바텀시트 안에서 바텀시트를 다시 여는 흐름 없음
- 정보성 시트의 닫기 버튼 위치
- 액션 시트의 닫기 / 주요 액션 배치
- `ResourceIconGrid`, `DetailLines`, `AppEmptyState`, `SectionCard` 사용 누락
- 모달 폭, 패딩, 제목 크기 일관성

대상 파일:
- `lib/common/widgets/resource_icon_grid.dart`
- `lib/common/widgets/app_empty_state.dart`
- `lib/common/widgets/catalog_asset_icon.dart`
- `lib/common/widgets/app_toast.dart`
- `lib/common/widgets/list_card.dart`
- `lib/common/widgets/info_card.dart`
- `lib/common/widgets/section_card.dart`
- `lib/common/widgets/app_sheet_layout.dart`
- `lib/common/widgets/app_dialog_layout.dart`
- `lib/features/workshop/extraction/presentation/widgets/workshop_extraction_sheet.dart`
- `lib/features/workshop/crafting/presentation/widgets/workshop_material_craft_tab.dart`
- `lib/features/workshop/inventory/presentation/widgets/workshop_inventory_tabs.dart`
- `lib/features/town/presentation/widgets/sheets/town_potion_sale_sheet.dart`
- `lib/features/town/presentation/widgets/sheets/town_equipment_sheet.dart`
- `lib/features/characters/presentation/widgets/character_equipment_item_grid.dart`

확인된 이슈:
- `ResourceIconGrid`는 항상 `Center`를 사용하므로 아이템 1개도 가운데 정렬된다.
- 그리드는 사용처와 무관하게 항상 왼쪽부터 채워야 한다.
- tooltip에 이름, 수량, 품질, 비용, 시간 같은 상세 정보가 `\n`으로 과하게 들어간다.
- `AppEmptyState`는 `Center(child: Text(message))`만 제공해 시트 안에서 위치와 톤을 조정하기 어렵다.
- `CatalogAssetIcon`은 `BorderRadius.circular(10)` raw 값을 사용하고 semantic label 옵션이 없다.
- `AppToast`는 radius에 spacing 값을 사용하고, 배경색을 `0xDD212121`로 하드코딩한다.
- `ListCard`와 `InfoCard`는 모두 `ListTile` 기반이지만 subtitle overflow / line 수 정책이 다르다.
- `SectionCard`는 trailing이 긴 버튼일 때 title 영역을 압박할 수 있다.
- `AppSheetLayout`과 `AppDialogLayout`은 `닫기 + 주요 액션` 패턴을 각 feature가 직접 구성하게 둔다.

구현 계획:
- `ResourceIconGrid`는 옵션 없이 항상 왼쪽부터 채우도록 변경한다.
- `ResourceIconGrid`의 중앙 정렬용 width 계산이 불필요해지면 제거한다.
- tooltip은 이름과 핵심 수량 중심으로 줄이고, 상세 정보는 모달 본문에서 `DetailLines`로 보여준다.
- `AppEmptyState`는 기본 텍스트 스타일을 `onSurfaceVariant`로 낮추고, 필요하면 compact / alignment 옵션을 추가한다.
- `CatalogAssetIcon`은 radius를 `AppRadius`로 통일하고 semantic label 옵션을 추가한다.
- `AppToast`는 radius를 `AppRadius`로 바꾸고 theme 기반 색상 사용을 검토한다.
- `ListCard`와 `InfoCard`는 title / subtitle overflow와 line 수 정책을 맞춘다.
- `SectionCard`는 trailing overflow 대응이 필요한지 점검한다.
- `AppSheetLayout` / `AppDialogLayout` action API 확장은 영향 범위가 커서 feature 폴리싱 중 반복 문제가 확인된 뒤 적용한다.

1차 적용 범위:
- `ResourceIconGrid` 왼쪽 채움
- `CatalogAssetIcon` radius / semantic 정리
- `AppToast` radius / theme 색상 정리
- `ListCard` / `InfoCard` overflow 정책 통일
- `AppEmptyState` 스타일 보강

보류:
- `AppSheetLayout` / `AppDialogLayout`의 action API 확장
- `SectionCard` 구조 확장

완료 기준:
- 공통 컴포넌트를 쓰지 않는 예외가 있으면 이유가 명확하다.
- 종료 액션이 body 안에 흩어져 있지 않다.
- 모바일 폭에서 주요 버튼과 텍스트가 겹치지 않는다.

### 3.2 Workshop 폴리싱
최근 변경이 많고 사용 빈도가 높으므로 1차 feature 폴리싱 대상으로 둔다.

상위 확인 항목:
- 연금술 시트의 양조 / 제작 / 레시피북 / 연구 탭 위계
- 양조 실험 결과 모달의 제목, 포션명, 품질, 레시피 갱신 액션 위계
- 제작 상세 모달의 재료 아이콘, 보유 수량, 제작 수량 슬라이더, 결과 표시
- 추출 상세 모달의 재료 그리드와 선택 후 상세 흐름
- 작업 큐 수령 화면의 수령 예정, 이미 반영된 성과, 보조 요약 순서
- 인챈트 / 부화 / 보조 슬롯 시트의 정보 밀도

대상 파일:
- `lib/features/workshop/craft_queue/presentation/widgets/workshop_queue_job_list.dart`
- `lib/features/workshop/crafting/presentation/widgets/workshop_craft_card.dart`
- `lib/features/workshop/crafting/presentation/widgets/workshop_material_craft_detail_dialog.dart`
- `lib/features/workshop/extraction/presentation/widgets/workshop_material_extraction_detail.dart`
- `lib/features/workshop/crafting/presentation/widgets/workshop_brew_experiment_result_body.dart`

확인된 이슈:
- 작업 큐 리스트 subtitle에 `제작 / 수령 대기\n결과` 형태의 줄 연결이 남아 있다.
- 연금술 시트 header에 큐 경고와 탭이 같이 있어 위계가 약하다.
- 제작 상세 모달의 `결과`, `제작 수량`, `필요 재료`, `소요 시간`이 같은 텍스트 무게로 표시된다.
- 추출 상세와 제작 상세의 섹션 제목 / 간격 기준이 완전히 같지 않다.

구현 계획:
- 작업 큐 리스트 subtitle을 `DetailLines`로 교체한다.
- 작업 타입, 상태, 결과를 행 단위로 분리한다.
- 연금술 시트의 큐 가득 참 경고를 탭과 시각적으로 분리한다.
- 제작 상세 모달 상단에 결과 아이콘과 결과 수량을 summary로 강화한다.
- 제작 시간, 정수, 신비, 원소 비용은 `DetailLines`로 정리한다.
- 추출 상세도 같은 섹션 제목 스타일과 간격 기준을 적용한다.

완료 기준:
- 주요 작업은 한 화면에서 등록 가능 여부와 비용을 바로 판단할 수 있다.
- 상세 정보는 모달로 분리되며, 리스트 본문에 긴 설명이 쌓이지 않는다.
- 재료 / 원소 / 포션 선택은 가능한 한 같은 그리드 표현을 사용한다.

### 3.3 Battle 폴리싱
전투는 반복 확인 화면이 많으므로 보상, 상태, 기록의 위계를 정리한다.

상위 확인 항목:
- 보상 수령 모달의 수령 보상과 이미 반영된 성과 구분
- 진행 시간, 성공 / 실패, 경험치 표시의 보조 정보 처리
- 전투 현황 시트의 현재 효과, 적 정보, 드롭 정보 표시
- stage 선택 화면의 해금 조건과 진행도 문구
- 최근 전투 기록의 접힌 상태 요약

대상 파일:
- `lib/features/battle/presentation/widgets/battle_claim_dialog.dart`
- `lib/features/battle/presentation/screens/dungeon_screen.dart`
- `lib/features/battle/presentation/widgets/battle_stage_status_sheet.dart`

확인된 이슈:
- 보상 수령 모달은 현재 방향이 맞으므로 큰 구조 변경 대상이 아니다.
- `재료 없음`은 공통 empty/보조 텍스트 패턴과 맞춰볼 수 있다.
- `DungeonScreen` stage 카드 summary가 `편성 N명\n상태: X` 단일 텍스트다.
- 전투 현황 시트는 기능보다 카드 간 정보 우선순위 점검이 필요하다.

구현 계획:
- stage 카드 summary를 `DetailLines` 또는 행 구조로 분리한다.
- 보상 수령 모달은 수령 예정 / 이미 반영된 경험치 구분을 유지한다.
- 재료 없음 표현만 공통 빈 상태 또는 약한 보조 텍스트로 정리한다.
- 전투 현황 시트는 spacing과 카드 순서만 점검하고 기능 변경은 하지 않는다.

완료 기준:
- 수령 버튼을 누르면 무엇이 지급되는지 즉시 알 수 있다.
- 경험치처럼 이미 반영된 값은 수령 예정 보상과 섞이지 않는다.
- 잠금 조건과 해금 진행도가 같은 규칙으로 표현된다.

### 3.4 Town 폴리싱
Town은 구매, 판매, 제작처럼 비용 판단이 많은 화면을 정리한다.

상위 확인 항목:
- 상점 품절, 구매 제한, 재입고 시간, 강제 갱신 비용 표시
- 포션 판매 선택 그리드와 판매 상세 모달
- 장비 제작 비용, 제작 시간, 보유 재료 표시
- 용병 고용 비용과 후보 갱신 액션
- Town 스킬트리 강화 가능 / 불가 상태

대상 파일:
- `lib/features/town/presentation/widgets/sheets/town_shop_sheet.dart`
- `lib/features/town/presentation/widgets/sheets/town_potion_sale_sheet.dart`
- `lib/features/town/presentation/widgets/sheets/town_equipment_sheet.dart`
- `lib/features/town/presentation/widgets/sheets/town_mercenary_hire_sheet.dart`

확인된 이슈:
- 상점 header에 상태 정보와 `강제 갱신` 액션이 같이 있다.
- 상점 item subtitle에 `가격 / 품절\n다음 재입고` 문자열 연결이 남아 있다.
- 포션 판매 상세 모달은 `Text + SizedBox` 반복이며 `DetailLines`를 쓰지 않는다.
- 장비 상세 모달도 `DetailLines`를 쓰지 않는다.

구현 계획:
- 상점 header는 구매 제한 / 재입고 상태만 표시한다.
- 강제 갱신 버튼은 `AppSheetLayout.footer`로 이동한다.
- 상품 subtitle은 `DetailLines`로 가격, 재고, 품절, 재입고를 분리한다.
- 포션 판매 상세와 장비 상세는 `DetailLines`로 교체한다.
- 용병 고용은 이미 footer에 후보 갱신이 있으므로 후순위 점검으로 둔다.

완료 기준:
- 비용 부족, 품절, 제한 도달 상태가 일반 설명과 분리되어 보인다.
- 구매 / 판매 / 제작 액션은 footer 또는 명확한 액션 영역에 있다.
- 원문 ID가 사용자 화면에 노출되지 않는다.

### 3.5 Characters 폴리싱
Characters는 성장 상태와 배치 상태를 빠르게 읽는 화면으로 정리한다.

상위 확인 항목:
- 캐릭터 카드의 레벨, 랭크, 티어, 전투력 위계
- XP progress와 수치 표시의 균형
- 랭크업 / 티어업 가능 여부와 부족 조건
- 장비 장착 선택 UI
- 전투 배치, 작업실 보조 배치, 대기 상태 문구

대상 파일:
- `lib/features/characters/presentation/widgets/character_equipment_sheet.dart`
- `lib/features/characters/presentation/widgets/character_equipment_detail_dialog.dart`
- `lib/features/characters/presentation/widgets/character_detail_sheet.dart`
- `lib/features/characters/presentation/widgets/character_growth_section.dart`

확인된 이슈:
- `CharacterEquipmentSheet`와 `CharacterEquipmentDialog`가 같은 콘텐츠를 `_CharacterEquipmentPresentation` enum으로 분기한다.
- Workshop에서 제거했던 sheet/dialog 이중 presentation 패턴이 Characters에 남아 있다.
- 장비 상세 모달은 `DetailLines`를 쓰지 않는다.
- 캐릭터 상세 title이 `${name} / ${type}` 형태라 문구 통일 단계에서 재검토할 수 있다.

구현 계획:
- 장비 선택이 실제로 dialog 진입만 쓰는지 확인한다.
- 미사용 sheet presentation이면 제거하고 dialog 흐름으로 고정한다.
- 장비 상세 모달은 `DetailLines`로 교체한다.
- 성장 섹션의 XP 수치와 최대 레벨 표시는 기존 기각 판단에 따라 유지한다.

완료 기준:
- 성장 가능한 캐릭터와 막힌 캐릭터를 빠르게 구분할 수 있다.
- 장착 / 해제 / 교체 흐름에서 대상과 결과가 명확하다.
- 배치 상태 문구가 Battle / Workshop과 충돌하지 않는다.

### 3.6 문구 통일
화면별 표현 차이를 줄인다.

상위 확인 항목:
- `수령 예정`, `수령 완료`, `이미 반영`, `대기 중`, `진행 중`
- `양조`, `제작`, `추출`, `인챈트`, `부화`
- `골드`, `정수`, `명성`, `신비`, `원소`
- `부족`, `잠금`, `품절`, `재입고`, `최대`
- 버튼 라벨의 동사형 통일

대상 검색:
- `rg '\\n' lib/features -g '*.dart'`
- `rg ' / ' lib/features -g '*.dart'`
- `rg '제조|제작|양조|수령 예정|이미 반영|수령 완료|대기 중|진행 중|품절|재입고|부족|잠금' lib/features -g '*.dart'`

우선 대상:
- Workshop queue의 `제작 / 수령 대기`
- Town shop의 `가격 / 품절`
- Dungeon card의 `편성 N명\n상태: X`
- 장비 / 포션 tooltip의 긴 `\n` 설명
- `제조`, `제작`, `양조` 혼용 가능 지점

구현 계획:
- 화면 본문 문자열을 먼저 정리한다.
- tooltip / semantic 문자열은 2순위로 정리한다.
- label formatter의 `\n` 반환은 실제 UI 사용처를 확인한 뒤 유지 여부를 결정한다.

완료 기준:
- 같은 상태가 feature마다 다른 단어로 표시되지 않는다.
- 내부 ID나 개발용 용어가 사용자 화면에 남지 않는다.
- 버튼 라벨은 결과가 분명한 동사로 끝난다.

## 4. 실행 순서
1. 공통 UI 컴포넌트 폴리싱
2. Workshop 폴리싱
3. Battle 폴리싱
4. Town 폴리싱
5. Characters 폴리싱
6. 문구 통일
7. 최종 점검

## 5. 최종 점검
- `flutter analyze`를 실행한다.
- 변경 범위와 직접 관련된 테스트만 실행한다.
- 문서만 수정한 경우 테스트를 생략할 수 있다.
- UI 변경 후에는 주요 모바일 폭에서 overflow를 확인한다.
- 새 테스트는 핵심 상호작용이나 회귀 위험이 있을 때만 추가한다.
