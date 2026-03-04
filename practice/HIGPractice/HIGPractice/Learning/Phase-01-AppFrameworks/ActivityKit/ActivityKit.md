# ActivityKit

## 학습 소스
- site: `site/activitykit/01-delivery-tracker.html`
- issue: #11
- branch: `practice/p1-activitykit-core`

## Ring 1 — Live Activity 개요
### 개념 요약
- Live Activity는 잠금화면과 Dynamic Island에 실시간 상태를 노출한다.
- 핵심 목표는 "짧고 즉시 이해 가능한 진행 상태"를 전달하는 것이다.
- 과도한 업데이트보다 의미 있는 상태 변경 중심으로 갱신한다.

### 내가 이해한 바
- Live Activity는 "지금 상태가 무엇인지"를 한눈에 보여주는 UI여야 하며, 상세 설명보다 진행 신호(상태/시간/진행률)가 우선이다.
- 앱은 상태를 만들고 업데이트하는 주체, 위젯 확장은 그 상태를 렌더링하는 주체라는 역할 분리가 핵심이다.
- 학습 단계에서는 앱 내 패널로 lifecycle을 반복 테스트하고, 운영 단계에서는 서버 이벤트 기반 업데이트로 전환해야 한다.

## Ring 2 — 데이터 모델 설계
### 개념 요약
- `ActivityAttributes`에 고정 정보, `ContentState`에 변하는 상태를 둔다.
- 상태 모델은 작고 직관적으로 유지한다.

### 내가 구현한 것
- [x] `ActivityAttributes` 정의
- [x] `ContentState` 정의
- [x] 앱/위젯 공통 모델(`Shared/DeliveryTracker`)로 통합

### 검증
- [x] 상태 변화가 모델 구조에 자연스럽게 반영되는지 확인
- [x] 앱/위젯의 상태 enum 불일치(중복 모델 문제) 제거

### 회고
- 초기에는 앱/위젯에 모델이 중복되어 상태 케이스가 어긋날 위험이 있었다.
- 공통 모델로 정리하면서 업데이트 계약(상태/필드)이 일관돼 유지보수가 쉬워졌다.

## Ring 3 — Activity Lifecycle
### 개념 요약
- 시작: `Activity.request(...)`
- 업데이트: `activity.update(...)`
- 종료: `activity.end(...)`

### 내가 구현한 것
- [x] 시작(request)
- [x] 업데이트(update)
- [x] 종료(end)
- [x] `SafeActivityManager` 기반 안전 호출 래퍼 적용
- [x] `DeliveryActivityDebugPanel`로 로컬 lifecycle 테스트 흐름 구성

### 검증
- [x] 시작 후 Lock Screen 반영 확인
- [x] 상태 업데이트 반영 확인
- [x] 종료 처리 반영 확인

### 회고
- `start 실패(ActivityInput error)`는 로컬 테스트에서 pushType 설정 문제와 연관이 있었다.
- 로컬 학습은 `pushType: nil` 경로가 안정적이었고, remote push 테스트는 환경 제약(`simctl push`)을 고려해야 했다.

## Ring 4 — UI 구성 (Lock Screen / Dynamic Island)
### 개념 요약
- Lock Screen: 핵심 상태 + 시간/진행 정보 중심
- Dynamic Island: compact/minimal/expanded 컨텍스트별 밀도 조절
- 작은 영역일수록 텍스트보다 상태 신호를 우선한다.

### 내가 구현한 것
- [x] Lock Screen UI
- [x] Dynamic Island compact
- [x] Dynamic Island expanded
- [x] 미사용 학습용 뷰 정리 후 실사용 Live Activity UI 경로로 통합

### 검증
- [x] compact/minimal/expanded 전환 시 레이아웃 안정성 확인

### 회고
- 실사용 경로가 아닌 앱 보조 뷰들이 혼재되어 있어 UI 관리 포인트가 분산되어 있었다.
- 위젯 확장 쪽 실사용 뷰만 중심으로 재구성해 구조가 단순해졌다.

## Ring 5 — HIG 적용 점검
### 개념 요약
- glanceable 정보 우선
- 과도한 색/애니메이션 지양
- 의미 있는 이벤트에서만 업데이트

### 내가 적용한 체크리스트
- [x] 핵심 KPI/상태 1~2개 우선 노출
- [x] 텍스트 길이 최소화
- [x] 갱신 타이밍 근거 명시

### 회고
- Lock Screen에서는 상태 메시지/ETA/진행단계 중심으로 정보 밀도를 정리했다.
- Dynamic Island는 compact/minimal에서 아이콘/타이머 중심으로 축약했다.

## 최종 정리
- 오늘 배운 핵심 3가지:
  1. ActivityKit은 앱(상태 제어)과 위젯(상태 렌더)의 책임 분리가 가장 중요하다.
  2. 모델 중복은 앱/위젯 계약 불일치의 원인이 되므로 공통 모델 1세트가 안전하다.
  3. 로컬 학습 단계는 패널 기반 lifecycle 테스트와 Logger/Monitor 관찰이 가장 빠르다.
- 다음 액션:
  1. push token 발급/전송 포함 remote update 흐름을 서버 시나리오로 확장
  2. Activity 종료 정책(`dismissalPolicy`)과 staleDate 전략을 서비스 기준으로 정리
