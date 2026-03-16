# [학습] Phase 1 - SwiftData

- label: `learning`
- branch: `learning/swiftdata-taskmaster`
- issue: `#23`

## 학습 Phase
- Phase 1: App Frameworks

## Framework 이름
- SwiftData

## 이번 학습 목표
- `TaskMaster`를 기준으로 SwiftData의 앱 연결 지점을 설명할 수 있다.
- `@Model`, `ModelContainer`, `ModelContext`, `@Query`, `#Predicate`의 역할을 구분할 수 있다.
- `Create / Read / Update / Delete` 흐름이 `TaskMaster` 안에서 어디서 일어나는지 정리한다.
- SwiftData와 `UserDefaults`, `Keychain`의 저장 목적과 적용 범위를 비교 설명할 수 있다.
- 이후 `Observation` 학습으로 자연스럽게 넘어갈 수 있도록 데이터 흐름 메모를 남긴다.

## 작업 체크리스트
- [ ] site 개념 확인
- [ ] tutorials 실습
- [ ] samples 구조 비교
- [ ] `TaskMasterApp.swift` 읽고 container/context 연결 방식 정리
- [ ] `TaskItem.swift`, `Category.swift` 읽고 모델/관계 정의 정리
- [ ] `ContentView.swift`에서 `@Query`와 메모리 필터링 경계 정리
- [ ] `AddTaskView.swift`에서 create 흐름 정리
- [ ] `TaskDetailView.swift`에서 update/delete 흐름 정리
- [ ] `DataService.swift`에서 `FetchDescriptor`, `#Predicate`, 정렬 패턴 정리
- [ ] SwiftData vs UserDefaults vs Keychain 비교 메모 작성
- [ ] PR 생성 및 CI 확인
- [ ] 머지 후 `LEARNING_LOG`/Velog 기록

## 완료 조건 (Definition of Done)
- `TaskMaster` 기준 SwiftData 핵심 파일 7개의 역할을 스스로 설명할 수 있다.
- `@Query`와 `FetchDescriptor`의 사용 기준을 말할 수 있다.
- 왜 SwiftData가 `UserDefaults`나 `Keychain`의 대체재가 아닌지 설명할 수 있다.
- `SwiftData.md`에 파일별 메모와 비교 정리가 남아 있다.

## 학습 목표에 대한 답

### `TaskMaster`를 기준으로 SwiftData의 앱 연결 지점을 설명할 수 있다
- 앱 연결 시작점은 `TaskMasterApp.swift`의 `ModelContainer` 주입이다.
- 앱 루트에서 `.modelContainer(sharedModelContainer)`를 붙여야 하위 View가 같은 저장소를 기준으로 `@Environment(\.modelContext)`와 `@Query`를 사용할 수 있다.
- 즉 모델 정의는 `TaskItem`, `Category`에 있고, 저장소 연결은 앱 루트에 있고, 실제 CRUD는 각 View와 `DataService`에 흩어져 있다.

### `@Model`, `ModelContainer`, `ModelContext`, `@Query`, `#Predicate`의 역할을 구분할 수 있다
- `@Model`: SwiftData가 저장 가능한 모델로 인식하는 선언이다. 예: `TaskItem`, `Category`
- `ModelContainer`: 앱의 저장소 루트다. 어떤 모델들을 관리할지와 persistence 설정을 가진다.
- `ModelContext`: 생성, 수정, 삭제, fetch 같은 실제 작업 문맥이다.
- `@Query`: SwiftUI View 안에서 선언형으로 데이터를 읽고, 변경 시 UI 갱신까지 연결하는 방식이다.
- `#Predicate`: `FetchDescriptor`와 함께 쓰는 타입 안전한 조건식이다. 서비스/로직 코드에서 직접 쿼리 조건을 만들 때 유용하다.

### `Create / Read / Update / Delete` 흐름이 `TaskMaster` 안에서 어디서 일어나는지 정리한다
- Create: `AddTaskView.swift`에서 입력을 `@State`로 모은 뒤 `TaskItem(...)` 생성 후 `modelContext.insert(...)`
- Read: `ContentView.swift`에서 `@Query`로 `allTasks`, `categories`를 읽고 화면 상태로 메모리 필터링
- Update: `TaskDetailView.swift`에서 `@Bindable var task`를 통해 제목, 메모, 우선순위, 카테고리 등을 직접 수정
- Delete: `TaskDetailView.swift`와 `ContentView.swift`에서 `modelContext.delete(...)`, 대량 삭제는 `DataService.swift`

### SwiftData와 `UserDefaults`, `Keychain`의 저장 목적과 적용 범위를 비교 설명할 수 있다
- SwiftData: 구조화된 앱 데이터 저장소다. 목록, 관계, 정렬, 필터가 필요한 모델 데이터에 적합하다.
- UserDefaults: 가벼운 설정 저장소다. 온보딩 여부, 마지막 선택 탭 같은 작은 값 저장에 적합하다.
- Keychain: 보안 정보 저장소다. 토큰, 비밀번호, 키 같은 민감 정보 저장에 적합하다.
- 따라서 SwiftData는 일반 앱 데이터용이고, UserDefaults는 설정용이고, Keychain은 보안용이라 서로 대체재가 아니다.

### 이후 `Observation` 학습으로 자연스럽게 넘어갈 수 있도록 데이터 흐름 메모를 남긴다
- 이번 SwiftData 학습으로 "저장된 데이터가 어떻게 View 갱신과 연결되는가"를 정리했다.
- 다음 Observation 학습에서는 이 흐름을 "상태 소유권"과 "읽기 추적" 관점에서 다시 볼 수 있다.
- 즉 SwiftData가 저장 계층이라면, Observation은 그 상태가 화면에서 읽히고 갱신되는 계층을 더 선명하게 보여준다.
