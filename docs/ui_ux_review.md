# UI/UX 검토 보고서

> 최초 검토: 2026-05-14 / 2차 검토: 2026-05-14 / 3차 검토: 2026-06-01

범례: ✅ 수정 완료 / ⚠️ 수정 필요 / 🔍 확인 필요

---

## 1. 불필요한 정보 표시

### ✅ 1-1. AppBar 다이아몬드 — 수량 미표시
- `lib/app/app.dart` — `state.player.diamonds` 바인딩으로 수정 완료

### ✅ 1-2. CharacterCombatEffectSection — 빈 상태 처리 없음
- `lib/features/characters/presentation/widgets/character_detail_sheet.dart` — `effectLines.isNotEmpty` 조건 추가 완료

### ✅ 1-3. WorkshopLogCard — 미사용 잔존 UI 제거
- `lib/features/workshop/dashboard/presentation/widgets/workshop_log_card.dart`
- 구현은 되어 있었으나 `WorkshopScreen` 자식 목록에는 없었다.
- 히스토리 확인 결과, 예전 `workshop_sections.dart`에는 export가 있었지만 `WorkshopScreen`에 실제로 붙어 있었던 흔적은 찾지 못함.
- 실제 로그는 전투, 마을, 작업실, 캐릭터 성장 로그가 섞인 전역 활동 로그라 작업실 전용 카드로 유지하기 어렵다.
- **처리**: 미사용 카드 파일과 전용 selector를 제거했다.

---

## 2. 디자인 시스템 위배

### ✅ 2-1. Workshop 탭 카드 이름 영한 혼용
- "Craft Queue" → "제작 대기열", "Craft" → "포션 제작" 등 한국어 통일 완료

### ✅ 2-2. Scaffold 중첩 패턴
- `WorkshopEnchantSheet`, `WorkshopHatchSheet`, 추가 확인된 `WorkshopMaterialExtractionDetail`에서 중첩 `Scaffold`/`Builder` 제거 완료

### ✅ 2-3. 작업실 자원 카드 — ListCard 전환 역효과
- `InfoCard`를 추가하고 마을 경제/작업실 자원 카드를 클릭 불가 정보 카드로 통일 완료

### ✅ 2-4. info-only 카드 패턴 미정의
- `common/widgets/info_card.dart` 추가 완료

### ✅ 2-5. ListCard trailing chevron 항상 표시
- `list_card.dart` — `onTap == null ? null : const Icon(Icons.chevron_right)` 처리 완료

### ✅ 2-6. CharacterCard — InkWell vs Card borderRadius 불일치
- `InkWell` 반경을 `AppRadius.card`로 통일 완료

### ✅ 2-7. BattleResultSheet — 색상 하드코딩
- 성공/실패 아이콘 색을 `colorScheme.primary` / `colorScheme.error`로 교체 완료

### ✅ 2-8. 하드코딩된 수치
- `battle_assignment_sheet.dart` 패딩을 `AppSpacing` 상수로 교체 완료

---

## 3. 디자인 시스템에 없는 UI 패턴

### ✅ 3-1. 섹션 카드 패턴 3중 중복 구현
- `common/widgets/section_card.dart` 추가 후 Character/Battle/Workshop support 섹션에 적용 완료

### ✅ 3-2. 뱃지 컴포넌트 (`_GrowthBadge`) — private 위젯으로만 존재
- `common/widgets/app_badge.dart` 추가 후 캐릭터 성장 배지에 적용 완료

---

## 4. 과도한 정보 밀도

### ✅ 4-1. 스킬트리 시트 — ListTile subtitle에 6줄 텍스트
- `DetailLines`로 설명과 세부 항목을 분리해 적용 완료

### ✅ 4-2. 호문쿨루스 부화 시트 — ListTile subtitle에 6줄 텍스트
- `DetailLines`로 설명과 세부 항목을 분리해 적용 완료

---

## 5. 기타 UX

### ✅ 5-1. TownEquipmentSheet — expandBody 암묵적 의존
- 3개 `Expanded` 섹션을 단일 `ListView` 구조로 교체 완료

### ✅ 5-2. WorkshopSupportSheet — 후보 선택 UI 연결이 불명확
- 후보 선택과 설명을 같은 항목의 `ListTile`로 통합 완료

---

## 우선순위 요약

| 우선순위 | 이슈 |
|---|---|
| 완료 | 2-2. Scaffold 중첩 패턴 |
| 완료 | 2-3/2-4. 작업실 자원 카드와 info-only 카드 패턴 |
| 완료 | 4-1/4-2. 스킬트리·부화 시트 6줄 subtitle |
| 완료 | 2-6. CharacterCard InkWell borderRadius 불일치 |
| 완료 | 2-7. BattleResultSheet 색상 하드코딩 |
| 완료 | 3-1. 섹션 카드 패턴 3중 중복 |
| 완료 | 5-1. TownEquipmentSheet expandBody 암묵적 의존 |
| 완료 | 2-8. 하드코딩된 패딩 |
| 완료 | 3-2. 뱃지 컴포넌트 미정의 |
| 완료 | 5-2. SupportSheet 선택 UX 불명확 |
| 완료 | 1-3. WorkshopLogCard 미사용 잔존 UI 제거 |

---

## 3차 검토 — 2026-06-01 (bfcd560 이후 구현분)

범례: ✅ 수정 완료 / ⚠️ 수정 필요 / 🔍 확인 필요

### ✅ 6-1. `workshopQueueCardSummaryProvider.description` 미사용
- `lib/features/workshop/craft_queue/presentation/viewmodels/craft_queue_job_selectors.dart`
- `description` 필드에 `'진행 없음 / 슬롯 0/5 / 수령 대기 0건'` 형식의 요약을 계산하지만, `WorkshopScreen`에서는 `WorkshopQueueCard(jobCount: queueSummary.jobCount)`처럼 `jobCount`만 사용하고 `description`은 완전히 무시된다.
- 권장: `WorkshopQueueCard`가 `description`도 받아 summary로 표시하거나, 사용하지 않는 필드와 계산 로직을 제거한다.
- **처리**: `WorkshopQueueCard`가 `description`을 받아 카드 summary에 표시하도록 연결했다.

### ✅ 6-2. 카드 이름과 시트 제목 불일치 (`연금술` → `제작`)
- `lib/features/workshop/crafting/presentation/widgets/workshop_craft_card.dart`
- 카드 이름은 `'연금술'`, 시트 제목은 `'제작'`
- `WorkshopResearchCard`(카드 `'연구'` / 시트 `'연구'`)는 일치하는데, `WorkshopCraftCard`만 불일치한다.
- 권장: 카드 이름을 `'제작'`으로 통일하거나, 시트 제목을 `'연금술'`로 맞춘다.
- **처리**: 시트 제목을 `'연금술'`로 변경해 카드 이름과 일치시켰다.

### ✅ 6-3. `WorkshopJobType.craft`에 `'제조'` 레이블 혼용
- `lib/features/workshop/craft_queue/presentation/viewmodels/craft_queue_labels.dart`
- `WorkshopJobType.craft => '제조'`로 표시하지만, 완료 결과 텍스트는 `'제작 완료'` 또는 `'양조 완료'`로 분기된다.
- 큐 리스트 아이템에 `제조 / 수령 대기 \n 양조 완료 / ...` 형태로 '제조'와 '양조'가 혼용된다.
- 주의: `WorkshopJobType.craft`가 포션 양조와 재료 제작을 모두 담는 구조라 단순히 enum 라벨만 바꾸면 해결되지 않는다.
- 권장: `CraftQueueJob` 내용(`completedMaterials`, `potionId`, `completedPotion`)을 기준으로 큐 아이템의 표시 레이블을 `'제작'`/`'양조'`로 분기한다.
- **처리**: `craftQueueJobTypeLabel`을 추가해 craft 작업도 포션이면 `'양조'`, 재료 작업이면 `'제작'`으로 표시하도록 분리했다.

### ✅ 6-4. 원소 1개 선택 시 안내 메시지 중복
- `lib/features/workshop/crafting/presentation/widgets/workshop_research_card.dart:148`: `'원소를 하나 더 선택하세요'`
- 같은 파일 line 295 `_BrewPreviewPanel`: `'원소 2종 선택 필요'`
- 1개 선택 상태에서 두 메시지가 동시에 화면에 표시된다.
- 권장: `_BrewPreviewPanel`의 `status` 계산을 `selectedCount == 0`과 `selectedCount == 1`을 분리해 상태별로 한 곳에서만 안내한다. 슬라이더 위치의 인라인 텍스트는 제거한다.
- **처리**: 1개 선택 안내는 `_BrewPreviewPanel` 한 곳에서만 표시하고, 인라인 안내 문구를 제거했다.

### ✅ 6-5. `_BrewRatioSlider` `메인`/`서브` 레이블 어색함
- `lib/features/workshop/crafting/presentation/widgets/workshop_research_card.dart:251, 268`
- `'메인 55%'` / `'서브 45%'` — 게임 맥락에서 어색한 범용 표현.
- 권장: `'주 55%'` / `'부 45%'` 또는 원소 이름만 표시하고 슬라이더 양 끝에 비율 배치.
- **처리**: 실험 비율 슬라이더의 레이블을 `'주'`/`'부'`로 줄여 표시했다.

### ✅ 6-6. 수량 슬라이더 레이블 배치
- `lib/features/workshop/crafting/presentation/widgets/workshop_craft_card.dart:427–432`
- 왼쪽 `'선택 N개'`, 오른쪽 `'최대 N개'` — 선택 중인 값과 최대값이 동등하게 나란히 표시된다.
- 권장: 선택 수량을 더 크게 강조하고, `'최대 N개'`는 보조 텍스트로 처리한다.
- **처리**: 선택 수량을 `titleSmall`로 강조하고, 최대 수량은 보조 텍스트로 유지했다.

### ✅ 6-7. 양조 상세 다이얼로그에서 `'양조 가능 X회'` 위치
- `lib/features/workshop/crafting/presentation/widgets/workshop_craft_card.dart:196`
- 다이얼로그 정보 순서: 포션 아이콘 → 최고 등급 → 수량 슬라이더 → 발견 비율 → **양조 가능 X회**
- 수량을 선택하기 전에 최대 가능 횟수를 알아야 하는데, 정작 그 정보가 가장 아래에 있다.
- 권장: `'양조 가능 X회'`를 슬라이더 상단(또는 `'최대 N개'` 레이블 대체)으로 이동한다.
- **처리**: `'양조 가능 X회'`를 양조 수량 슬라이더 위로 이동했다.

### ✅ 6-8. `'소요 시간 Xs xN'` 표기 불명확
- `lib/features/workshop/crafting/presentation/widgets/workshop_craft_card.dart:362`
- `'소요 시간 30s x3'`이 "1회 30초 × 3번"인지 "총 90초"인지 불명확하다.
- 권장: `'1회 30s / 총 90s'` 또는 `'1회 ${recipe.durationLabel} · 총 ${계산값}'` 형식으로 명시한다.
- **처리**: 제작 상세 다이얼로그에서 `'소요 시간 1회 N / 총 M'` 형식으로 표시한다.

### ✅ 6-9. 빈 큐 상태 표현 불일치
- 카드 summary (`workshop_queue_card.dart:16`): `'대기 중 작업 없음'`
- 시트 내부 (`workshop_queue_sheet.dart:27`): `'큐가 비어있습니다'`
- 권장: 두 곳 중 하나로 통일. 예: `'대기 중인 작업이 없습니다'`.
- **처리**: 시트 빈 상태를 `'대기 중인 작업이 없습니다'`로 변경했다. 카드 summary는 `description` 기반 요약으로 교체되어 기존 불일치가 사라졌다.

### ✅ 6-10. 큐 가득 참 경고 스타일 없음
- `lib/features/workshop/crafting/presentation/widgets/workshop_craft_card.dart:71`
- `Text('작업실 큐 가득 참 ($N/$M)')` — 색상·아이콘 없는 plain text라 경고 의도가 전달되지 않는다.
- 권장: `colorScheme.error` 색상이나 경고 아이콘을 추가한다.
- **처리**: 경고 아이콘과 `colorScheme.error` 색상으로 표시한다.

### ✅ 6-11. tooltip 수량 표기 단위 없음
- `lib/features/workshop/crafting/presentation/widgets/workshop_craft_card.dart:114`
- `'양조 가능 ${recipe.maxCraftableCount}'` → `'양조 가능 5'`처럼 단위가 없다.
- 권장: `'양조 가능 ${recipe.maxCraftableCount}회'`로 통일.
- **처리**: 양조 레시피 tooltip에 `회` 단위를 추가했다.

---

## 4차 검토 — 2026-06-01 (불필요한 정보 / 디자인 시스템 위배 / 위계 붕괴)

범례: ✅ 수정 완료 / ⚠️ 수정 필요

---

### A. 불필요한 정보

### ✅ 7-1. 경험치 수치 — 프로그레스바와 중복 지적 기각
- `lib/features/characters/presentation/widgets/character_growth_section.dart:61–62`
- `'${character.xp} / ${character.xpToNextLevel}'` 가 프로그레스바 오른쪽에 raw 숫자로 표시된다.
- **기각**: RPG 성장 UI에서 프로그레스바는 비율 감각, raw XP 수치는 정확한 진행량을 제공하므로 중복이 아니라 보완 관계다. 현재 표시를 유지한다.

### ✅ 7-2. 최대 레벨 표시 — 액션과 무관한 메타 정보 지적 기각
- `lib/features/characters/presentation/widgets/character_growth_section.dart:68–73`
- `'최대 레벨 ${character.maxLevelForRank}'` — 현재 랭크의 레벨 상한이지만, 유저가 취할 수 있는 액션(랭크업/티어업)과 직접 연결되지 않는다. 랭크업 조건은 이미 버튼 활성/비활성으로 전달된다.
- **기각**: 랭크/티어 구조에서 현재 성장 상한을 설명하는 기준 정보다. 버튼 상태만으로는 “왜 더 성장하지 않는지”를 충분히 설명하지 못하므로 현재 표시를 유지한다.

### ✅ 7-3. 보상 수령 다이얼로그 — 런 요약 정보의 위계
- `lib/features/battle/presentation/widgets/battle_claim_dialog.dart:36–43`
- "런 요약" 섹션에 `'성공 X회 / 실패 Y회'`, `'진행 시간 N분'`, `'경험치 +N'`이 표시된다.
- 경험치는 전투 성공 시점에 이미 캐릭터에게 반영되고, `claimStageRewards`에서는 골드/정수/재료만 지급한다. 따라서 경험치를 "수령 예정"으로 옮기면 실제 처리와 어긋난다.
- 권장: 경험치는 "이미 반영된 성과"로 런 요약에 남기되, 골드/정수/재료 수령 예정 보상보다 시각적으로 약하게 둔다. 성공/실패 횟수와 진행 시간도 방치 성과 확인용 보조 정보로 유지한다.
- **처리**: 수령 예정 보상을 먼저 배치하고, 런 요약을 뒤로 내려 보조 정보로 정리했다. 경험치는 `'이미 반영된 경험치'`로 표시한다.

### ✅ 7-4. 부화 시트 header — 보유 호문쿨루스 수 불필요
- `lib/features/workshop/hatchery/presentation/widgets/workshop_hatch_sheet.dart:26`
- `'정수 $essence / 신비 $arcaneDust / 보유 호문쿨루스 $homunculusCount체'`
- `homunculusCount`(현재 보유 수)는 부화 가능 여부와 무관하다. 부화 가능 여부는 이미 각 레시피의 `availabilityLabel`에 표시된다.
- 권장: header에서 `/ 보유 호문쿨루스 $homunculusCount체` 제거.
- **처리**: 부화 시트 header에서 보유 호문쿨루스 수를 제거했다.

---

### B. 디자인 시스템 위배

### ✅ 7-5. 인챈트 확인 다이얼로그 body에 `\n` 연결 텍스트
- `lib/features/workshop/enchanting/presentation/widgets/workshop_enchant_sheet.dart:33–39`
- `Text('${preview.equipmentName}\n현재 ${preview.currentEnchantLabel}\n변경 ${preview.nextEnchantLabel}\n...')` — 6개 정보가 `\n`으로 하나의 `Text`에 구겨진다.
- 기준: "subtitle에 `\n`으로 줄을 구겨 넣는 패턴" 은 ui_design_gaps.md §1에서 수정 완료로 처리됐으나, 이 다이얼로그는 누락됐다.
- 권장: `DetailLines`로 분리.
- **처리**: 교체 확인 다이얼로그 body를 `DetailLines`로 교체했다.

### ✅ 7-6. 인챈트 등록 버튼이 body 안에 위치
- `lib/features/workshop/enchanting/presentation/widgets/workshop_enchant_sheet.dart:114–124`
- `FilledButton`이 `SingleChildScrollView` body 마지막에 인라인으로 배치된다. 스크롤이 짧을 때는 괜찮으나, 선택 항목이 많아지면 버튼이 스크롤 영역 아래로 사라진다.
- 기준: "액션 바텀시트는 footer에 닫기와 주요 액션을 함께 정리한다" (ui_design_system_guidelines.md).
- 권장: `AppSheetLayout(footer:)` 파라미터로 버튼을 이동.
- **처리**: 인챈트 등록 버튼을 `AppSheetLayout.footer`로 이동하고 닫기 버튼과 함께 고정 액션 영역으로 정리했다.

### ✅ 7-7. `_DetailRows` — `DetailLines`의 중복 구현
- `lib/features/workshop/inventory/presentation/widgets/workshop_resource_detail_dialogs.dart:68–88`
- `_DetailRows`는 `Column → Padding → Text` 구조로 `DetailLines`와 동일한 역할이지만, `DetailLines`의 `bodySmall` + `onSurfaceVariant` 스타일을 적용하지 않아 일반 `bodyMedium`으로 렌더된다.
- 권장: `_DetailRows` 삭제 후 세 다이얼로그 모두 `DetailLines`로 교체.
- **처리**: `_DetailRows`를 삭제하고 재료/원소/포션 상세 다이얼로그를 모두 `DetailLines`로 교체했다.

### ✅ 7-8. 보조 슬롯 현황 — `/` 연결 텍스트
- `lib/features/workshop/support/presentation/widgets/workshop_support_sheet.dart:44–45`
- `Text('현재 ${slot.assignedCharacterName} / 효과 ${slot.effectLabel}')` — 두 정보가 `/`로 단일 `Text`에 합쳐진다.
- 권장: `DetailLines`로 분리.
- **처리**: 현재 배치와 효과를 `DetailLines`의 개별 행으로 분리했다.

### ✅ 7-9. `BattleClaimDialog._ClaimSection` — `SectionCard`/`DetailLines` 미사용 독자 구현
- `lib/features/battle/presentation/widgets/battle_claim_dialog.dart:106–128`
- `_ClaimSection`은 `Text(title, style: titleSmall)` + `Padding → Text` 목록 구조다. `SectionCard`(섹션 제목) + `DetailLines`(행 목록) 패턴과 완전히 동일한 역할을 별도로 구현했다.
- 권장: `_ClaimSection` 삭제 후 `SectionCard` + `DetailLines`로 교체.
- **처리**: `_ClaimSection` 내부 구현을 `SectionCard` + `DetailLines`로 교체했다.

### ✅ 7-10. `CharacterCombatEffectSection` — `DetailLines` 미사용 독자 구현
- `lib/features/characters/presentation/widgets/character_combat_sections.dart:43–51`
- `effectLines`를 `Padding(bottom: xs) + Text`로 나열하는 구조가 `DetailLines`와 동일하나, `bodySmall` + `onSurfaceVariant` 색상이 적용되지 않아 본문 텍스트와 동일하게 렌더된다.
- 권장: `DetailLines(lines: effectLines)`로 교체.
- **처리**: 전투 효과 목록을 `DetailLines`로 교체했다.

---

### C. 위계 붕괴

### ✅ 7-11. 인챈트 미리보기 — 현재/예상/변화량이 동일 weight
- `lib/features/workshop/enchanting/presentation/widgets/workshop_enchant_sections.dart:147–155`
- `현재 인챈트`, `예상 인챈트`, `현재 스탯`, `예상 스탯`, `변화량` 5행이 같은 `bodyMedium` 스타일로 나열된다. 유저에게 가장 중요한 정보(변화량 `deltaStatLabel`)가 시각적으로 강조되지 않는다.
- 권장: `equipmentName`(이미 subsectionTitle) + 인챈트 행(`DetailLines` 보조 스타일) + `deltaStatLabel`(`dataEmphasis` 강조) 3단 위계로 정리.
- **처리**: 현재/예상 정보는 `DetailLines`로 낮추고, 변화량은 `dataEmphasis`로 강조했다.

### ✅ 7-12. 스킬트리 노드 다이얼로그 — 현재/다음 효과 레이블 구분 없음
- `lib/common/widgets/skill_tree_node_detail_dialog.dart:37–42`
- `'현재 효과 ${node.currentEffectLabel}'`과 `'다음 효과 ${node.nextEffectLabel}'`이 같은 `DetailLines.lines` 배열에 동일 스타일로 렌더된다. 업그레이드 대상인 "다음 효과"가 현재 효과보다 강조되어야 하는데 시각적으로 동등하다.
- 권장: `description`에 현재 효과, `lines`에 `'다음 효과'`를 배치해 `bodyMedium`/`bodySmall` 계층 활용. 또는 `dataEmphasis` 스타일을 다음 효과에 적용.
- **처리**: 현재 효과는 `DetailLines`에 유지하고, 다음 효과는 별도 `dataEmphasis` 텍스트로 분리했다.

### ✅ 7-13. 보조 슬롯 header — 배치 수와 요약 문장이 동일 weight
- `lib/features/workshop/support/presentation/widgets/workshop_support_sheet.dart:29`
- `'배치 $assignedCount/$slotLimit명 / $summary'` — 슬롯 점유 수(숫자)와 `summary`(문장 길이 텍스트)가 `/`로 이어진다. header는 한눈에 상태를 파악하는 자리인데, 긴 summary가 함께 붙어 스캔이 어렵다.
- 권장: header는 `'배치 $assignedCount/$slotLimit명'`만 두고, summary는 body 상단 또는 각 슬롯 카드 내부로 이동.
- **처리**: header에는 배치 수만 남기고, summary는 body 상단의 보조 텍스트로 이동했다.

### ✅ 7-14. 작업실 스킬트리 header — `'신비 N'` 레이블 없이 단독 수치
- `lib/features/workshop/skill_tree/presentation/widgets/workshop_skill_tree_sheet.dart:23`
- `Text('신비 $arcaneDust')` — "신비"가 리소스 이름인지 레이블인지 맥락 없이 수치만 나온다. 다른 시트들은 `'슬롯 N/M'`, `'배치 N/M명'`처럼 수치의 의미를 포함한다.
- 권장: `'신비 $arcaneDust (강화 재화)'` 또는 `'보유 신비: $arcaneDust'` 형태로 컨텍스트 명시. 또는 아이콘과 함께 표시.
- **처리**: header 문구를 `'보유 신비: $arcaneDust'`로 변경했다.

---

### 3·4차 통합 우선순위 요약

✅ 3·4차 검토의 수정 필요 항목은 모두 처리 완료.
