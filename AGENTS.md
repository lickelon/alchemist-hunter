# AGENTS.md

이 저장소의 구조 원칙과 레이어 책임의 기준 문서는 아래 파일이다.

- [docs/project_structure_principles.md](./docs/project_structure_principles.md)

## 적용 방식
- 새 기능 추가, 파일 이동, 레이어 분리, 네이밍 변경 전에는 위 문서를 먼저 따른다.
- 구조 관련 판단이 필요할 때는 이 파일보다 위 문서를 우선 기준으로 본다.
- 이 파일에는 중복 설명을 쌓지 않고, 에이전트가 바로 실수하기 쉬운 최소 규칙만 둔다.

## 최소 필수 규칙
- 구조 기준은 `feature-first`
- 레이어 기준은 `presentation / domain / data`
- 전역 상태 저장소는 `core/session` 기준으로 다룬다
- `domain`은 모델과 비즈니스 규칙 전용이다
- `application`은 신규 구조의 기준이 아니며, 기존 코드 정리 중간 단계로만 본다
- 새 코드는 가능하면 `application`을 늘리지 말고 목표 구조로 배치한다
- feature 전용 코드를 `common`, `core`, 최상위 `services`, 최상위 `utils`로 올리지 않는다
- 구조 대칭만 맞추기 위한 리팩토링은 하지 않는다
- 파일 이동보다 책임 명확화와 테스트 경계 유지가 우선이다

## 작업 시 판단 순서
1. 이 코드가 어느 feature의 책임인지 먼저 정한다
2. UI 조립인지, 비즈니스 규칙인지, 데이터 접근인지 분리한다
3. 순수 계산이면 `domain/services`, 액션 흐름이면 `domain/use_cases`에 둔다
4. 전역 상태 저장/부트스트랩만 `core` 또는 `app`에 둔다

## 테스트 기준
- 구조 변경 시 해당 feature 테스트 위치도 함께 맞춘다
- use case와 domain service는 단위 테스트 우선
- widget 테스트는 핵심 상호작용과 사용자 문구 중심으로 유지한다
