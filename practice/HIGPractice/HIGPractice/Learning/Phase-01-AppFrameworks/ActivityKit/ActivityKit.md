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
- (작성)

## Ring 2 — 데이터 모델 설계
### 개념 요약
- `ActivityAttributes`에 고정 정보, `ContentState`에 변하는 상태를 둔다.
- 상태 모델은 작고 직관적으로 유지한다.

### 내가 구현한 것
- [ ] `ActivityAttributes` 정의
- [ ] `ContentState` 정의

### 검증
- [ ] 상태 변화가 모델 구조에 자연스럽게 반영되는지 확인

### 회고
- (작성)

## Ring 3 — Activity Lifecycle
### 개념 요약
- 시작: `Activity.request(...)`
- 업데이트: `activity.update(...)`
- 종료: `activity.end(...)`

### 내가 구현한 것
- [ ] 시작(request)
- [ ] 업데이트(update)
- [ ] 종료(end)

### 검증
- [ ] 시작 후 Lock Screen 반영 확인
- [ ] 상태 업데이트 반영 확인
- [ ] 종료 처리 반영 확인

### 회고
- (작성)

## Ring 4 — UI 구성 (Lock Screen / Dynamic Island)
### 개념 요약
- Lock Screen: 핵심 상태 + 시간/진행 정보 중심
- Dynamic Island: compact/minimal/expanded 컨텍스트별 밀도 조절
- 작은 영역일수록 텍스트보다 상태 신호를 우선한다.

### 내가 구현한 것
- [ ] Lock Screen UI
- [ ] Dynamic Island compact
- [ ] Dynamic Island expanded

### 검증
- [ ] compact/minimal/expanded 전환 시 레이아웃 안정성 확인

### 회고
- (작성)

## Ring 5 — HIG 적용 점검
### 개념 요약
- glanceable 정보 우선
- 과도한 색/애니메이션 지양
- 의미 있는 이벤트에서만 업데이트

### 내가 적용한 체크리스트
- [ ] 핵심 KPI/상태 1~2개 우선 노출
- [ ] 텍스트 길이 최소화
- [ ] 갱신 타이밍 근거 명시

### 회고
- (작성)

## 최종 정리
- 오늘 배운 핵심 3가지:
  1.
  2.
  3.
- 다음 액션:
  1. Push 업데이트 흐름 학습
  2. 실제 서비스 시나리오(배달/운동/택시) 중 1개 확장
