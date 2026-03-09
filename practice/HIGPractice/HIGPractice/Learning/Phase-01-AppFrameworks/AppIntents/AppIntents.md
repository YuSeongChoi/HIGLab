# App Intents

## 학습 소스
- site: `site/appintents/01-siri-todo-app.html`
- sample: `samples/SiriTodo`
- issue: #16
- branch: `practice/p1-appintents-siritodo`

## Ring 1 - App Intents 개요
### 개념 요약
- App Intents는 앱 기능을 Siri/Shortcuts/Spotlight에 노출하는 실행 인터페이스다.
- 핵심은 "UI 없이도 실행 가능한 앱 기능 단위"를 정의하는 것이다.
- Widget/ActivityKit처럼 별도 화면 렌더링 프레임워크가 아니라, 액션 실행 프레임워크에 가깝다.

### 내가 이해한 바
- 시작은 메인 앱 로직을 안정화하고, Intent는 그 로직을 호출하는 진입점으로 붙이는 방식이 안전하다.
- 처음부터 위젯 연동까지 가지 않고, `AddTodoIntent` 단일 성공 경로를 먼저 완주해야 한다.

## Ring 2 - 최소 Intent 1개 완주(AddTodo)
### 개념 요약
- 최소 구현: 파라미터 입력 -> 도메인 로직 호출 -> 결과 반환(`.result`).
- 성공/실패 메시지는 Shortcuts/Siri 사용자 경험에 직접 노출된다.

### 내가 구현할 것
- [ ] `AddTodoIntent` 입력 파라미터(예: 제목) 정의
- [ ] Todo 저장 로직 연결
- [ ] 성공/실패 결과 메시지 정리

### 검증
- [ ] Shortcuts에서 `AddTodoIntent` 실행 성공
- [ ] 실행 후 앱 데이터(Todo 목록) 반영 확인
- [ ] 실패 케이스(빈 제목 등) 메시지 확인

## Ring 3 - App Shortcut 노출
### 개념 요약
- Intent 자체와 Shortcut 노출은 별개다.
- Phrase/Title은 호출성과 인식률에 직접 영향이 있다.

### 내가 구현할 것
- [ ] `AppShortcutsProvider` 등록
- [ ] 한국어/영어 호출 문구 정리
- [ ] 표시 이름/설명 정리

### 검증
- [ ] Shortcuts 앱에서 액션 검색 가능
- [ ] 문구 기반 호출 시 동작 확인

## Ring 4 - 파라미터 확장
### 개념 요약
- 기능 확장은 "필수 1개 + 선택 1~2개"부터 확장하는 것이 안전하다.
- 옵션이 늘수록 기본값/유효성/로컬라이징 품질이 중요해진다.

### 내가 구현할 것
- [ ] 우선순위/마감일 등 선택 파라미터 추가
- [ ] 기본값 정책 정리
- [ ] 입력 유효성 체크 추가

### 검증
- [ ] 파라미터 조합별 실행 결과 확인
- [ ] 비정상 입력 방어 확인

## Ring 5 - 연동 확장(선택)
### 개념 요약
- App Intents 단독 안정화 이후 Widget/ActivityKit 연동을 붙인다.
- 연동은 "트리거 경로 추가"이지, App Intents 학습의 필수 1단계는 아니다.

### 내가 구현할 것
- [ ] 위젯 버튼 액션 연동 필요성 검토
- [ ] Live Activity 업데이트 트리거 연동 필요성 검토

### 검증
- [ ] 연동 전후 책임 분리(실행 vs 렌더링) 유지 확인

## 지금 단계에서의 결론
- `Home -> FrameworkDetailView`에서 App Intents는 ActivityKit처럼 버튼 패널이 "필수"는 아니다.
- 우선은 학습 순서/검증 기준 카드로 충분하다.
- 실제 실행 테스트는 Shortcuts/Siri 경로에서 검증하는 것이 더 정확하다.

## 최종 정리
- 오늘 배울 핵심 3가지:
  1. App Intents는 UI 프레임워크가 아니라 앱 기능 실행 인터페이스다.
  2. 최소 Intent 1개 완주가 확장보다 중요하다.
  3. 위젯/ActivityKit 연동은 2단계다.
- 다음 액션:
  1. `samples/SiriTodo` 기반 `AddTodoIntent` 최소 구현
  2. Shortcuts 실행 검증 후 실패 메시지/유효성 정리
  3. 필요 시 Widget/ActivityKit 트리거 연동 검토

## Troubleshooting

### 1) `Main actor-isolated conformance ... cannot satisfy ...`
- 증상:
  - `Main actor-isolated conformance of 'Tag' to DisplayRepresentable/Identifiable cannot satisfy conformance requirement`
- 원인:
  - 프로젝트 설정이 `Default Actor Isolation = MainActor`라서 타입/멤버가 기본적으로 메인 액터 격리로 추론됨.
  - 하지만 `AppEntity` 관련 프로토콜 요구사항 일부는 nonisolated 문맥을 요구함.
- 해결:
  - `AppEntity` 요구 멤버(`typeDisplayRepresentation`, `displayRepresentation`, `defaultQuery`)에 `nonisolated` 명시.
  - `Identifiable` 충돌 시 `id` 등 필요한 멤버에 `nonisolated` 명시.

### 2) `Type 'Tag' does not conform to protocol 'AppEntity' / 'AppValue'`
- 증상:
  - `Type 'Tag' does not conform to protocol 'AppEntity'`
  - `Type 'Tag' does not conform to protocol 'AppValue'`
- 원인:
  - 액터 격리 불일치 또는 `AppEntity` 필수 요구사항 미충족.
  - `numericFormat: "\(placeholder: .int)..."` 구문이 SDK/문법 호환 이슈를 유발하며 연쇄 오류를 만들 수 있음.
- 해결:
  - `TypeDisplayRepresentation(name: "...")`로 단순화(`numericFormat` 제거).
  - `defaultQuery` 및 `displayRepresentation` 포함 필수 멤버를 정확히 구현.

### 3) `TagQuery`에서 저장소 접근 시 격리 에러
- 증상:
  - `TagStore.shared.tags` 접근에서 actor-isolated 접근 관련 에러 발생.
- 원인:
  - 저장소가 메인 액터 문맥인데, 쿼리 함수는 비격리 문맥에서 실행됨.
- 해결:
  - `TagStore`에 `@MainActor` 명시.
  - `EntityQuery` 함수 내부에서 `await MainActor.run { ... }`로 짧게 읽기/필터 수행.

### 정리 원칙
- 프로젝트 전체 `Default Actor Isolation`은 유지한다.
- 충돌 지점(프로토콜 요구 멤버/저장소 접근)만 국소적으로 `nonisolated` 또는 `MainActor.run` 적용한다.
