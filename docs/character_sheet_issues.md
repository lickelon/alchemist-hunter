# UI 문제 목록

> 정리 기준: `master` 브랜치 커밋 `f9d93c0` 기준  
> 범위: character, battle, town, workshop presentation 레이어 전반

---

## 작업 요약

- `c5ea4e9` `Refine character sheet around localized progression and clearer detail summaries`
  - character 상세 시트 구조 정리, dead code 제거, 성장/액션 문구 한글화
- `cbcd18d` `Refine potion displays around named stacks and formatted traits`
  - 포션 이름/특성 표시 정리, `stackKey` 노출 제거
- `c85b34f` `Refine battle and town labels around localized stage and resource text`
  - town/battle 자원 라벨, 스테이지 표기, 타이머 단위 정리
- `0182b98` `Refine workshop inventory and craft sheets around clearer resource labels`
  - workshop rarity/특성 수치/지원 로그/큐 안내 문구 정리
- `f9d93c0` `Refine town skill tree labels around localized prerequisites and costs`
  - town 스킬트리 선행 조건, 비용, 헤더 문구 정리

## 정책상 유지

- `15. 포션 qualityLabel`
  - `S/A/B/C` raw 품질 코드는 그대로 노출하기로 결정
- `20. 포션 scoreLabel`
  - raw score는 그대로 노출하기로 결정

---

## ~~1. "총합 스탯" 섹션 — 이름 불일치 + 중복~~ ✅ 수정 완료

## ~~2. `summaryLine` — 데드 코드~~ ✅ 수정 완료

## ~~3. `characterTierMaterialLabel` — 내부 키 노출~~ ✅ 수정 완료

## ~~4. `characterAssignmentLabel` — 스테이지 키 반노출~~ ✅ 수정 완료

## ~~5. `CharacterGrowthSection` — 영한 혼용~~ ✅ 수정 완료

## ~~6. "액션" 섹션 버튼 — 영문~~ ✅ 수정 완료

## ~~7. 섹션 배치 순서 어색함~~ ✅ 수정 완료

## ~~8. 용병 "프로필" — 내용 빈약 + combat job 미반영~~ ✅ 수정 완료

## ~~9. `buildStats()` 이중 호출~~ ✅ 수정 완료

## ~~10. `resolvedCombatJobId` 기본값 불일치~~ ✅ 수정 완료

## ~~11. Town 화면 — 카드 제목 전반 영문~~ ✅ 수정 완료

## ~~12. Dungeon / Battle 결과 화면 — 스테이지 키 반노출 + 자원 레이블 영문~~ ✅ 수정 완료

## ~~13. `MaterialRarity.name` 직접 표시 — 3곳~~ ✅ 수정 완료

## ~~14. 포션 `stackKey` — UI 직접 노출~~ ✅ 수정 완료

## 15. 포션 `qualityLabel` — 등급 코드 직접 노출

정책상 유지. `S/A/B/C` raw 품질 코드를 그대로 노출한다.

## ~~16. 포션 `traitsLabel` — `Map.toString()` 직접 사용~~ ✅ 수정 완료

## ~~17. Town 스킬트리 — `prerequisiteLabel`에 노드 ID 노출~~ ✅ 수정 완료

## ~~18. Town 스킬트리 — 비용/레벨/헤더 영한 혼용~~ ✅ 수정 완료

## ~~19. Workshop 지원 배치 — 영문 로그~~ ✅ 수정 완료

## 20. 포션 `scoreLabel` — raw 품질 점수 노출

정책상 유지. raw score를 그대로 노출한다.

## ~~21. 추출 특성 `amount` — 단위 없는 raw 소수점~~ ✅ 수정 완료

## ~~22. Dungeon 화면 — 글로벌 자원이 스테이지 카드마다 중복 표시~~ ✅ 수정 완료

## ~~23. Battle 결과 로그 — Gold/Essence 영문 + 부호 로직 불일치~~ ✅ 수정 완료

## ~~24. 타이머 단위 영문 `s`~~ ✅ 수정 완료

## ~~25. 포션 카탈로그 이름 — 플레이스홀더 데이터~~ ✅ 수정 완료

## ~~26. "큐 가득 참" — 전역 상태를 모든 아이템 subtitle에 반복~~ ✅ 수정 완료

## ~~27. 잠금 조건 — 영문 재료 이름 하드코딩~~ ✅ 수정 완료

---

## 현재 상태

- presentation 기준 미해결 이슈는 남기지 않음
- 포션 `qualityLabel`, `scoreLabel`만 정책상 유지
