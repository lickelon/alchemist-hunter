# UI/UX 검토 보고서

> 최초 검토: 2026-05-14 / 2차 검토: 2026-05-14

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
