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

### 현재 구현 상태
- [x] `TodoItem`, `Priority`, `DueDatePreset`, `Tag` 등 Intent 입력/출력에 필요한 공유 모델 정리
- [x] `TodoStore`, `TagStore` 기반 저장/조회 경로 정리
- [ ] `AddTodoIntent` 본체 작성
- [ ] `perform()`에서 저장소 호출 후 결과 대화문 반환

### 내가 구현할 것
- [ ] `AddTodoIntent` 입력 파라미터(예: 제목) 정의
- [ ] Todo 저장 로직 연결
- [ ] 성공/실패 결과 메시지 정리

### 검증
- [ ] Shortcuts에서 `AddTodoIntent` 실행 성공
- [ ] 실행 후 앱 데이터(Todo 목록) 반영 확인
- [ ] 실패 케이스(빈 제목 등) 메시지 확인

### 회고
- 현재는 "Intent가 붙을 도메인 바닥"까지는 준비됐고, 실제 액션 진입점만 비어 있는 상태다.
- 이 단계에서는 새 Intent를 여러 개 만드는 것보다 `AddTodoIntent` 1개를 완주해 `perform()` 패턴을 고정하는 편이 낫다.

## Ring 3 - App Shortcut 노출
### 개념 요약
- Intent 자체와 Shortcut 노출은 별개다.
- Phrase/Title은 호출성과 인식률에 직접 영향이 있다.

### 현재 구현 상태
- [ ] `AppShortcutsProvider` 미구현
- [ ] 앱 이름 포함 phrase/localization 미정리

### 내가 구현할 것
- [ ] `AppShortcutsProvider` 등록
- [ ] 한국어/영어 호출 문구 정리
- [ ] 표시 이름/설명 정리

### 검증
- [ ] Shortcuts 앱에서 액션 검색 가능
- [ ] 문구 기반 호출 시 동작 확인

### 회고
- Intent 구현과 Shortcut 노출을 한 번에 붙이면, 실패 지점을 구분하기 어려워진다.
- 순서는 `Intent 실행 성공 -> Shortcuts 검색 노출 -> phrase 다듬기`가 가장 디버깅하기 쉽다.

## Ring 4 - 파라미터 확장
### 개념 요약
- 기능 확장은 "필수 1개 + 선택 1~2개"부터 확장하는 것이 안전하다.
- 옵션이 늘수록 기본값/유효성/로컬라이징 품질이 중요해진다.

### 현재 구현 상태
- [x] `Priority`를 `AppEnum`으로 노출할 기반 준비
- [x] `DueDatePreset`을 `AppEnum`으로 노출할 기반 준비
- [x] `Tag`를 `AppEntity`로 검색 가능한 형태로 준비
- [ ] 실제 Intent 파라미터에 연결 전

### 내가 구현할 것
- [ ] 우선순위/마감일 등 선택 파라미터 추가
- [ ] 기본값 정책 정리
- [ ] 입력 유효성 체크 추가

### 검증
- [ ] 파라미터 조합별 실행 결과 확인
- [ ] 비정상 입력 방어 확인

### 회고
- 파라미터 타입 준비를 먼저 해둔 덕분에, `AddTodoIntent`에 어떤 선택값을 붙일지 결정하기 쉬워졌다.
- 다만 첫 Intent에서는 `title + priority` 정도까지만 붙이고, `dueDate/tag`는 2차 확장으로 미루는 편이 안전하다.

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

## 현재 구현 상태 요약
- 완료:
  - Todo/Tag/Priority/DueDate 공통 모델링
  - `AppEntity`, `AppEnum`, `EntityQuery` 기반 타입 설계
  - `TodoStore`, `TagStore` 저장/조회 경로 정리
- 미완료:
  - `AddTodoIntent` 실제 실행 로직
  - `AppShortcutsProvider` 등록
  - App Group 기반 실데이터 공유 검증

## 바로 다음 구현 순서
1. `AddTodoIntent`에 `title` 필수 파라미터만 먼저 붙인다.
2. `perform()`에서 `TodoStore.shared.add(...)` 호출 후 `IntentResult` 대화문을 반환한다.
3. 실행이 확인되면 `priority`를 선택 파라미터로 추가한다.
4. 마지막에 `AppShortcutsProvider`와 phrase를 붙여 Shortcuts 검색/호출을 검증한다.

## 최종 정리
- 오늘 배울 핵심 3가지:
  1. App Intents는 UI 프레임워크가 아니라 앱 기능 실행 인터페이스다.
  2. 최소 Intent 1개 완주가 확장보다 중요하다.
  3. 위젯/ActivityKit 연동은 2단계다.
- 다음 액션:
  1. `samples/SiriTodo` 기반 `AddTodoIntent` 최소 구현
  2. Shortcuts 실행 검증 후 실패 메시지/유효성 정리
  3. 필요 시 Widget/ActivityKit 트리거 연동 검토

## 실제 적용 플로우

### 1) 도메인 타입을 먼저 정리한다
- Intent부터 만들지 않고, 먼저 `TodoItem`, `Priority`, `Tag`, `DueDate` 같은 공용 타입을 정리한다.
- 이 단계의 목적은 "앱이 이미 이해하고 있는 도메인 모델"을 Siri/Shortcuts도 이해할 수 있게 바탕을 만드는 것이다.

### 2) 외부에서 참조할 데이터는 `AppEntity`/`AppEnum`으로 노출한다
- 사용자가 선택하거나 검색해야 하는 앱 데이터는 `AppEntity`로 노출한다.
- 선택지 성격의 값(`Priority`, `DueDatePreset`)은 `AppEnum`으로 노출한다.
- 즉:
  - `TodoItem`, `Tag` -> `AppEntity`
  - `Priority`, `DueDatePreset` -> `AppEnum`

### 3) 실제 동작은 `AppIntent`로 만든다
- App Intent는 "외부에서 호출 가능한 앱 동작"이다.
- 이번 샘플에서는 아래 흐름으로 정리했다.
  - `AddTodoIntent`: 새 할일 추가
  - `CompleteTodoIntent`: 할일 완료 처리
  - `ListTodosIntent`: 목록 조회
  - `SearchTodosIntent`: 검색
  - `OpenSiriTodoIntent`: 앱 열기

### 4) 저장소 접근은 메인 액터 규칙에 맞춘다
- `TodoStore`는 `@MainActor` 저장소로 두고,
- Intent나 Query에서는 필요한 순간만 `await MainActor.run { ... }`로 접근한다.
- 즉 App Intents에서 중요한 건:
  - 타입 자체를 무조건 메인 액터에 묶는 것
  - 가 아니라
  - 메인 액터 저장소 접근 구간만 정확히 격리하는 것이다.

### 5) 마지막에 `AppShortcutsProvider`를 붙인다
- Intent가 먼저 동작해야 Shortcut 노출 실패와 실행 실패를 구분할 수 있다.
- 그래서 구현 순서는:
  1. 도메인 타입 정리
  2. `AppEntity`/`AppEnum` 준비
  3. `AppIntent` 구현
  4. `AppShortcutsProvider` 등록
  5. Shortcuts/Siri에서 실제 테스트

## 이번 샘플에서 구현한 구조

### 공용 모델/저장소
- `TodoItem`
- `TodoStore`
- `Priority`
- `Tag`
- `DueDate`

### Intent 계층
- `AddTodoIntent`
- `CompleteTodoIntent`
- `DeleteTodoIntent`
- `ListTodosIntent`
- `SearchTodosIntent`
- `SetPriorityIntent`
- `OpenTodoIntent`

### Shortcut 노출 계층
- `AppShortcuts.swift`
- 현재는 학습용으로 최소 Shortcut 세트만 유지했다.
- 이유:
  - App Shortcut phrase 규칙이 생각보다 엄격하고
  - 한 앱이 가질 수 있는 Shortcut 개수 제한도 있기 때문이다.

### 샘플 UI 계층
- `SiriTodoSampleRootView`
- `SiriTodoSampleContentView`
- 홈에서 `App Intents` 카드 선택 시 이 샘플 화면으로 바로 이동하도록 연결했다.
- 문서형 상세 화면보다 "샘플 구조 + 테스트 순서 + 저장소 상태"를 함께 보는 쪽이 학습 효율이 더 높다고 판단했다.

## 이번 학습에서 정리된 App Intents 개념

### App Intents는 무엇인가
- 앱 기능을 Siri, Shortcuts, Spotlight 같은 시스템 진입점에 노출하는 실행 인터페이스다.
- 핵심은 "UI 없이 실행 가능한 앱 기능"을 정의하는 것이다.

### AppEntity는 무엇인가
- 시스템이 참조할 수 있는 앱 내부 데이터 타입을 등록하는 규약이다.
- 예를 들어 "어떤 할일을 완료할지"를 고르게 하려면 `TodoItem`이 `AppEntity`여야 한다.

### AppEnum은 무엇인가
- 고정된 선택지 값을 시스템에 알려주는 규약이다.
- 예를 들어 우선순위처럼 정해진 옵션은 `AppEnum`이 잘 맞는다.

### AppShortcutsProvider는 무엇인가
- 어떤 Intent를 어떤 문구로 노출할지 결정하는 등록 계층이다.
- Intent가 기능이라면, `AppShortcutsProvider`는 그 기능을 어떻게 부를지 정하는 레이어다.

## 이번 작업에서 실제로 맞닥뜨린 트러블슈팅

### 1) `Default Actor Isolation = MainActor`와 `AppEntity` 요구사항 충돌
- 문제:
  - 프로젝트 기본 설정 때문에 멤버가 자동으로 `MainActor`에 묶였다.
  - 그런데 `AppEntity`의 일부 요구사항은 비격리 멤버를 기대했다.
- 정리:
  - `nonisolated`는 "메인에서 저장한다/안 한다"가 아니라
  - "이 멤버는 특정 actor에 묶이지 않는다"는 뜻이다.
- 대응:
  - `displayRepresentation`, `typeDisplayRepresentation`, `defaultQuery` 등에 `nonisolated` 적용

### 2) `@MainActor` 저장소를 Query/Intent에서 바로 읽을 수 없었다
- 문제:
  - `TodoStore.shared.todos`는 메인 액터 보호 상태인데 Query는 비격리 문맥에서 실행될 수 있다.
- 대응:
  - `await MainActor.run { ... }`로 짧은 접근 구간만 메인 액터에 올렸다.

### 3) `OpenIntent`를 그대로 쓰면 요구사항이 더 많았다
- 문제:
  - 샘플의 `OpenSiriTodoIntent`, `OpenAddTodoIntent` 등이 `OpenIntent` 적합성 에러를 냈다.
- 원인:
  - `OpenIntent`는 일반 `AppIntent`보다 더 강한 요구사항(`target` 등)이 있다.
- 대응:
  - 현재 프로젝트 목적에 맞게 `AppIntent + openAppWhenRun = true` 구조로 단순화했다.

### 4) `nonisolated static var`는 저장 프로퍼티에서 바로 막혔다
- 문제:
  - `title`, `description`, `openAppWhenRun`, `shortcutTileColor` 등에 `nonisolated static var`를 붙이면
  - `mutable stored properties` 에러가 발생했다.
- 대응:
  - 값이 고정된 메타데이터는 `nonisolated static let`으로 정리했다.

### 5) `AppShortcuts`는 "빌드가 된다"와 "메타데이터가 유효하다"가 다르다
- 문제:
  - Swift 컴파일은 통과했는데 App Intents metadata export에서 실패했다.
- 실제 원인:
  - 각 phrase에 `\(.applicationName)`이 정확히 1번 들어가야 했다.
  - 파라미터 타입 제약도 더 엄격했다.
  - Shortcut 개수 제한도 있었다.
- 대응:
  - 학습용 최소 Shortcut 세트만 남기고 문구를 규칙에 맞게 단순화했다.

### 6) 독립 샘플 앱 구조를 그대로 가져오면 현재 앱 구조와 충돌한다
- 문제:
  - `@main`, `ContentView` 같은 독립 앱용 구조가 현재 프로젝트와 충돌했다.
- 대응:
  - 샘플 앱은 독립 실행 앱이 아니라 "학습용 샘플 뷰"로 재가공했다.
  - 홈의 `App Intents` 카드에서 `SiriTodoSampleRootView`로 이동하게 바꿨다.

## 지금 기준 실무 적용 원칙
- 도메인 모델을 먼저 만들고 Intent는 나중에 붙인다.
- `AppEntity`/`AppEnum`은 시스템이 이해할 데이터 타입을 등록하는 레이어다.
- `AppIntent`는 외부에서 실행할 기능 단위다.
- `AppShortcutsProvider`는 실행 기능을 시스템에 노출하는 등록 레이어다.
- actor 관련 문제는:
  - 비격리여야 하는 멤버 -> `nonisolated`
  - 메인 액터 저장소 접근 -> `await MainActor.run { ... }`
  로 나눠서 생각한다.

## 이번 작업의 완료 기준
- [x] SiriTodo 샘플 구조를 현재 프로젝트에 맞게 재가공
- [x] 기본 Intent 세트 정리
- [x] App Shortcut 최소 세트 등록
- [x] App Intents 학습 전용 샘플 화면 연결
- [x] 동시성/메타데이터/App Shortcut 관련 트러블슈팅 정리

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

### 4) Intent 실행은 되는데 앱/위젯 데이터와 동기화되지 않음
- 증상:
  - Shortcuts에서는 성공 메시지가 나오지만 앱을 열면 새 Todo가 보이지 않음.
- 원인:
  - Intent 확장과 앱이 서로 다른 `UserDefaults` 영역을 사용하고 있을 가능성이 큼.
  - App Group 식별자를 예시 값으로 두면 실제 공유 저장소가 연결되지 않는다.
- 해결:
  - 앱 타깃과 Intent/Widget 타깃에 동일한 App Group entitlement를 설정.
  - `TodoStore.appGroupIdentifier`를 실제 그룹 ID로 교체.
  - 공유 저장소 실패 시 `.standard`로 떨어지는 현재 fallback이 학습 중에는 동작을 가릴 수 있으므로, 실제 검증 단계에서는 그룹 연결 여부를 명확히 확인.

### 5) Shortcuts 앱에서 액션이 검색되지 않음
- 증상:
  - 빌드는 되지만 Shortcuts 검색창에 Intent/App Shortcut이 보이지 않음.
- 원인:
  - `AppShortcutsProvider` 미등록, phrase 미설정, 빌드 후 인덱싱 지연 등 여러 원인이 가능함.
- 해결:
  - 먼저 Intent 단독 구현 후 `AppShortcutsProvider`를 추가.
  - 앱 재설치 또는 기기 재부팅 없이도 보통 재빌드/실행 후 시간이 조금 지나면 인덱싱되지만, 학습 중에는 "노출 문제"와 "Intent 실패"를 분리해서 확인해야 한다.
  - 즉, 검색 노출 전에도 Shortcuts 앱의 앱 액션 목록이나 디버그 경로에서 Intent 존재 여부를 먼저 본다.

### 6) `perform()`에서 메인 액터 저장소 호출 시 동시성 경고/에러
- 증상:
  - Intent 내부에서 `TodoStore.shared` 접근 시 메인 액터 관련 경고가 발생하거나 호출 위치가 애매해짐.
- 원인:
  - 저장소는 `@MainActor`인데, Intent 실행 문맥은 항상 메인 액터가 아니다.
- 해결:
  - `perform()` 내부에서 저장/조회가 필요한 최소 범위만 `await MainActor.run { ... }`로 감싼다.
  - App Intent 타입 전체를 메인 액터에 묶기보다, 저장소 접근 구간만 격리하는 편이 의도가 명확하다.

### 정리 원칙
- 프로젝트 전체 `Default Actor Isolation`은 유지한다.
- 충돌 지점(프로토콜 요구 멤버/저장소 접근)만 국소적으로 `nonisolated` 또는 `MainActor.run` 적용한다.
- Shortcut 노출 문제와 Intent 실행 문제는 분리해서 디버깅한다.
- 데이터 공유 문제는 App Group 연결부터 먼저 의심한다.

## Concurrency Note

### 1) Thread와 공유 메모리
- 하나의 프로세스 안에는 여러 thread가 존재할 수 있다.
- 각 thread는 자기 stack을 가지지만, heap 같은 메모리는 공유한다.
- race condition의 핵심 원인은 "멀티 thread 자체"보다 "공유 가변 상태(shared mutable state)"다.

### 2) 왜 actor가 필요한가
- 여러 실행 문맥이 같은 가변 상태를 동시에 읽고 쓰면 데이터 오염이나 순서 꼬임이 생길 수 있다.
- Swift의 `actor`는 "이 상태는 이 actor가 책임진다"는 격리 규칙을 만들어 이런 접근을 제어한다.
- 즉 actor는 thread를 없애는 개념이 아니라, 공유 상태 접근을 안전하게 만드는 동시성 모델이다.

### 3) MainActor는 무엇인가
- `MainActor`는 UI와 메인 실행 문맥에 묶어야 하는 상태를 보호하는 global actor다.
- SwiftUI/UIKit/AppKit 작업은 보통 `MainActor`와 강하게 연결된다.
- 실무에서는 거의 "메인 thread에서 처리해야 하는 상태"라고 이해해도 된다.

### 4) 이번 AppEntity 에러의 본질
- 이 프로젝트는 `Default Actor Isolation = MainActor`라서 타입과 멤버가 기본적으로 메인 액터 격리로 추론될 수 있다.
- 그런데 `AppEntity`의 일부 요구사항(`typeDisplayRepresentation`, `displayRepresentation`, `defaultQuery`)은 메인 액터 전용 멤버가 아니라 비격리 멤버를 기대한다.
- 그래서 메인 액터에 묶인 상태로 두면 `Main actor-isolated conformance ... cannot satisfy ...` 같은 에러가 난다.

### 5) `nonisolated`는 무엇을 의미하나
- `nonisolated`는 "이 멤버는 특정 actor에 묶이지 않는다"는 뜻이다.
- 더 실무적으로는 "이 멤버는 actor 바깥에서도 안전하게 읽을 수 있다"는 선언이다.
- 한글로는 보통 `비격리 한정자` 정도로 이해하면 된다.
- 단, 아무 멤버에나 붙이는 것이 아니라 실제로 공유 상태 보호 없이도 안전한 값/계산에만 붙여야 한다.

### 6) 왜 저장소 접근은 `MainActor.run`이 필요한가
- `TodoStore`처럼 `@MainActor`로 보호된 저장소는 공유 상태를 가진다.
- 이런 상태는 actor 바깥에서 바로 읽거나 쓰면 안 된다.
- 그래서 `await MainActor.run { ... }`로 필요한 짧은 구간만 메인 액터 안에서 실행해 안전하게 접근한다.
- 즉 `nonisolated`는 "actor 보호가 필요 없는 멤버", `MainActor.run`은 "actor 보호가 필요한 상태 접근"에 대응한다.

### 7) 이번 예제에 적용하면
- `TodoItem.displayRepresentation`
  - `AppEntity` 요구사항 충족을 위해 `nonisolated`가 필요하다.
- `TodoItem.defaultQuery`
  - 메인 액터 격리가 아닌 문맥에서도 호출될 수 있으므로 `nonisolated`가 필요하다.
- `TodoStore.shared.todos`
  - `@MainActor` 저장소 상태이므로 `await MainActor.run { ... }` 안에서 접근해야 한다.

### 한 줄 정리
- `nonisolated` = 이 멤버는 actor 보호 없이도 안전하다.
- `await MainActor.run { ... }` = 이 상태는 actor 보호가 필요하니 메인 액터 안에서 접근한다.
