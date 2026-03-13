# SwiftData

## 학습 소스
- site: `site/swiftdata/01-tutorial.html`
- tutorials: `tutorials/swiftdata`
- sample: `samples/TaskMaster`
- ai-reference: `ai-reference/swiftdata.md`
- issue draft: `practice/HIGPractice/HIGPractice/Learning/Phase-01-AppFrameworks/SwiftData/ISSUE_DRAFT.md`
- issue: `#23`
- branch: `learning/swiftdata-taskmaster`

## 이번 학습 구조
- 이번 SwiftData 학습은 새 샘플을 따로 고르지 않고, 이미 SwiftUI에서 봤던 `TaskMaster`를 다시 읽는 방식으로 진행한다.
- 차이는 "UI 관점"이 아니라 "데이터 관점"으로 읽는다는 점이다.
- 즉 같은 프로젝트를 다시 보되, 아래 질문을 중심으로 따라간다.
  - 이 데이터는 어디서 정의되는가
  - 저장소는 앱에 어디서 연결되는가
  - 화면은 데이터를 어떻게 읽는가
  - 생성/수정/삭제는 어디서 일어나는가

## 이번 학습 방식
- 읽는 순서는 고정한다.
  1. `TaskMasterApp.swift`
  2. `TaskItem.swift`
  3. `Category.swift`
  4. `ContentView.swift`
  5. `AddTaskView.swift`
  6. `TaskDetailView.swift`
  7. `DataService.swift`
- 각 파일에서 "SwiftData 관점 메모"를 남긴다.
- 문법만 외우지 말고, `TaskMaster` 전체 데이터 흐름을 설명할 수 있는지까지 본다.

## 읽는 순서와 체크 포인트

### 1. `TaskMasterApp.swift`
- 파일: `samples/TaskMaster/TaskMasterApp/TaskMasterApp.swift`
- 여기서는 "SwiftData를 앱에 어떻게 붙이는가"만 본다.
- 완료 여부: [x]
- 체크 포인트
  - `Schema`
  - `ModelContainer`
  - `.modelContainer(sharedModelContainer)`
  - preview용 in-memory container

### 내가 적을 메모
- `ModelContainer`는 SwiftData 저장소의 시작점이다.
- 앱 루트에서 `.modelContainer(...)`를 주입해야 하위 View에서 `@Environment(\.modelContext)`와 `@Query`가 동작한다.
- preview에서는 in-memory container를 써서 실제 저장 파일을 건드리지 않는다.
- `Schema([TaskItem.self, Category.self])`는 "이 저장소가 어떤 모델들을 관리하는가"를 선언한다.
- `sharedModelContainer.mainContext`를 통해 기본 데이터 초기화가 일어난다.

## `TaskMasterApp.swift`를 보고 답할 질문
- 왜 `.modelContainer(...)`는 앱 루트에 붙이는가
- `sharedModelContainer`를 따로 만들어 두는 이유는 무엇인가
- preview container와 실제 container의 차이는 무엇인가

### 2. `TaskItem.swift`
- 파일: `samples/TaskMaster/Shared/TaskItem.swift`
- 여기서는 "SwiftData 모델이 어떻게 생겼는가"를 본다.
- 완료 여부: [x]
- 체크 포인트
  - `@Model`
  - 저장 프로퍼티
  - 계산 프로퍼티
  - 메서드가 모델 안에 들어가는 방식
  - `@Relationship(inverse:)`

### 내가 적을 메모
- `@Model`이 붙은 클래스는 SwiftData가 저장 가능한 모델로 인식한다.
- SwiftData가 모델의 identity와 변경 추적을 관리해야 하므로 `@Model`은 `class`에 붙는다.
- 일반 stored property는 저장 대상이 되고, 계산 프로퍼티는 저장되지 않는다.
- `toggleCompletion()`처럼 도메인 동작을 모델 안에 두면 View가 단순해진다.
- 관계는 `@Relationship`으로 정의하고, 역관계가 있으면 양쪽 연결을 더 명확히 이해할 수 있다.
- 실제 persisted 값은 `priority`, `dueDate`, `createdAt` 같은 stored property다.
- `taskPriority`, `daysUntilDue`, `isDueSoon`, `isOverdue`는 "저장된 값을 바탕으로 계산하는 뷰 친화적 접근자"다.
- `inverse`는 "이 관계의 반대편 프로퍼티가 무엇인지"를 지정한다.
- 양방향 관계는 Task가 Category를 알고, Category도 자신의 Task 목록을 아는 구조다.

## `TaskItem.swift`를 보고 답할 질문
- 왜 `@Model`은 `struct`가 아니라 `class`에 붙는가
- `daysUntilDue`, `isDueSoon`, `isOverdue`는 왜 저장 프로퍼티가 아닌가
- `taskPriority`는 persisted 값인가, 변환용 접근자인가

## 관계 메모

### `@Relationship`은 무엇인가
- SwiftData 모델끼리 연결 관계가 있다는 선언이다.
- 예를 들어 `TaskItem.category`는 "이 할 일이 어느 카테고리에 속하는가"를 나타낸다.

### 양방향 관계란 무엇인가
- 한쪽만 상대를 아는 것이 아니라, 양쪽 모델이 서로를 참조할 수 있는 관계다.
- 예:
  - `TaskItem.category` = 이 Task가 속한 Category
  - `Category.tasks` = 이 Category에 속한 Task 목록

### `inverse`는 무엇인가
- "이 관계의 반대편 프로퍼티가 무엇인지"를 SwiftData에 알려주는 설정이다.
- `@Relationship(inverse: \Category.tasks)`는
  `TaskItem.category`의 반대편이 `Category.tasks`라고 선언하는 의미다.

### 왜 필요한가
- SwiftData가 두 모델 사이 연결을 더 명확하게 이해한다.
- 한쪽에서 관계를 바꿨을 때 반대편 관계도 같은 연결로 해석할 수 있다.
- 즉 Task와 Category가 따로 노는 것이 아니라, 하나의 관계 양쪽 면으로 연결된다.

### 지금 단계에서 기억할 한 줄
- `@Relationship` = 모델 간 연결 선언
- `inverse` = 연결의 반대편 지정
- 양방향 관계 = 양쪽이 서로를 참조하는 구조

### 3. `Category.swift`
- 파일: `samples/TaskMaster/Shared/Category.swift`
- 여기서는 관계 모델을 본다.
- 체크 포인트
  - `Category`와 `TaskItem` 연결
  - 역관계가 왜 필요한가
  - 삭제 시 영향 추론

### 내가 적을 메모
- `Category`와 `TaskItem`은 1:N 관계다.
- 한 카테고리에 여러 개의 Task가 연결될 수 있다.
- 관계 정의를 보면 카테고리 삭제 시 Task가 같이 지워지는지, nil 처리되는지 추론할 수 있어야 한다.

## `Category.swift`를 보고 답할 질문
- 관계를 양쪽 모델에 다 적는 이유는 무엇인가
- 카테고리를 지우면 기존 Task는 어떻게 될까
- 이 모델에서 "카테고리 이름"과 "카테고리에 속한 Task 목록"은 성격이 어떻게 다른가

### 4. `ContentView.swift`
- 파일: `samples/TaskMaster/TaskMasterApp/ContentView.swift`
- 여기서는 "조회와 화면 연결"만 본다.
- 체크 포인트
  - `@Environment(\.modelContext)`
  - `@Query(sort: ...)`
  - 가져온 배열이 UI에 바로 반영되는 흐름
  - 검색/필터가 DB 쿼리인지, 메모리 필터인지 구분하기

### 내가 적을 메모
- `@Query`는 SwiftUI 화면 안에서 선언형으로 데이터를 읽는 가장 기본적인 방식이다.
- `allTasks`, `categories`는 저장소와 연결된 상태라 데이터가 바뀌면 화면도 갱신된다.
- 이 파일의 `filteredTasks`는 DB 필터가 아니라 메모리 필터다.
- 즉 현재 구조는 "먼저 `@Query`로 읽고, 그 결과를 다시 화면에서 가공"하는 방식이다.

## `ContentView.swift`를 보고 답할 질문
- `@Query`와 `filteredTasks`는 각각 어느 층의 역할인가
- 검색과 필터를 모두 `@Query`로 넣지 않고 메모리에서 거르는 이유는 무엇일까
- `modelContext.delete(task)` 후 왜 목록이 바로 갱신될까

### 5. `AddTaskView.swift`
- 파일: `samples/TaskMaster/TaskMasterApp/AddTaskView.swift`
- 여기서는 Create를 본다.
- 체크 포인트
  - 입력값을 모델로 바꾸는 위치
  - `context.insert(...)`가 일어나는 위치
  - 저장 호출이 따로 없는 이유

### 내가 적을 메모
- 사용자 입력은 `@State`로 모으고, 저장 시점에 `TaskItem` 인스턴스를 만든다.
- `modelContext.insert(...)`를 하면 SwiftData가 변경을 추적한다.
- 기본 autosave 흐름 덕분에 간단한 경우 명시적 `save()`가 없어도 된다.

## `AddTaskView.swift`를 보고 답할 질문
- 입력값을 왜 곧바로 모델에 바인딩하지 않고 `@State`로 먼저 받는가
- `insert`는 어떤 시점에 호출하는 게 가장 안전한가
- create 시 category 관계는 어디서 연결되는가

### 6. `TaskDetailView.swift`
- 파일: `samples/TaskMaster/TaskMasterApp/TaskDetailView.swift`
- 여기서는 Update/Delete를 본다.
- 체크 포인트
  - 모델 수정이 UI에 반영되는 흐름
  - `@Bindable`의 역할
  - `context.delete(...)` 호출 위치

### 내가 적을 메모
- SwiftData 모델은 변경 추적이 되기 때문에 프로퍼티 수정만으로도 상태 변화가 반영된다.
- `@Bindable`은 모델 프로퍼티를 폼 입력과 직접 연결할 때 중요하다.
- 삭제는 `modelContext.delete(...)`로 처리한다.

## `TaskDetailView.swift`를 보고 답할 질문
- `@Bindable var task: TaskItem`이 필요한 이유는 무엇인가
- 어떤 수정은 즉시 반영되고, 어떤 건 별도 액션 버튼이 필요할까
- 이 화면은 "편집 화면"인가, "상세 화면"인가, 아니면 둘 다인가

### 7. `DataService.swift`
- 파일: `samples/TaskMaster/Shared/DataService.swift`
- 여기서는 SwiftData를 코드에서 직접 다루는 패턴을 본다.
- 체크 포인트
  - `FetchDescriptor`
  - `#Predicate`
  - 정렬
  - 서비스 레이어로 분리하는 이유

### 내가 적을 메모
- `@Query`는 View 안에서 선언형으로 읽는 방식이고,
- `FetchDescriptor`는 서비스/로직 코드에서 직접 쿼리할 때 쓰는 방식이다.
- `#Predicate`는 문자열 기반이 아니라 타입 안전한 조건식을 제공한다.
- 서비스 레이어를 두면 View에서 쿼리 세부 구현을 덜어낼 수 있다.

## `DataService.swift`를 보고 답할 질문
- `@Query` 대신 `FetchDescriptor`를 쓴 이유는 무엇인가
- 이 서비스는 꼭 싱글톤이어야 하는가
- "조회 로직을 View에서 할지, 서비스로 뺄지" 기준은 무엇인가

## SwiftData 핵심 개념 요약

### `@Model`
- SwiftData가 저장 가능한 데이터 모델로 인식하게 만드는 매크로
- Core Data의 `.xcdatamodeld` 없이 순수 Swift 코드로 모델을 정의할 수 있다

### `ModelContainer`
- 저장소 전체를 감싸는 루트 객체
- 어떤 모델들을 저장할지 schema를 들고 있고, 실제 persistence 설정도 가진다

### `ModelContext`
- 생성, 수정, 삭제 같은 실제 작업이 일어나는 문맥
- `insert`, `delete`, `fetch`가 여기서 일어난다

### `@Query`
- SwiftUI View 안에서 선언형으로 데이터를 가져오는 방식
- 데이터 변경 시 UI 갱신까지 연결된다

### `FetchDescriptor`
- 코드에서 직접 fetch 조건을 만들고 싶은 경우 사용하는 쿼리 기술
- 서비스 레이어나 특정 로직에서 더 유연하다

### `#Predicate`
- 타입 안전한 필터 조건
- 문자열 기반 predicate보다 Swift 문법에 가깝고 안전하다

## SwiftData vs UserDefaults vs Keychain

### SwiftData는 무엇에 적합한가
- 앱의 구조화된 로컬 데이터 저장
- 여러 필드를 가진 모델
- 목록/관계/정렬/필터가 필요한 데이터
- 예: 할일, 카테고리, 메모, 기록, 로컬 캐시

### UserDefaults는 무엇에 적합한가
- 작은 설정값 저장
- 앱 상태 플래그
- 사용자의 간단한 선호값
- 예: 다크모드 설정, 온보딩 완료 여부, 마지막 선택 탭

### Keychain은 무엇에 적합한가
- 민감 정보 저장
- 보안이 중요한 인증 데이터
- 예: access token, refresh token, 비밀번호, 암호 키

## 차이를 한 문장씩 정리
- SwiftData: "구조화된 앱 데이터 저장소"
- UserDefaults: "가벼운 설정 저장소"
- Keychain: "보안 정보 저장소"

## 왜 서로 대체재가 아닌가
- SwiftData는 관계형/목록형 데이터에 강하지만, 민감 정보 저장 용도는 아니다.
- UserDefaults는 빠르고 단순하지만, 복잡한 모델/관계/검색에는 맞지 않는다.
- Keychain은 보안은 강하지만, 일반 앱 데이터 저장소처럼 다루기엔 무겁고 목적이 다르다.

## 예시로 구분해보기
- "할일 목록 저장"
  - SwiftData
- "사용자가 마지막으로 본 필터 상태 저장"
  - UserDefaults
- "로그인 토큰 저장"
  - Keychain

## 이번 학습 체크리스트
- [ ] `@Model`은 왜 `class`에 붙는지 설명할 수 있다
- [ ] `.modelContainer(...)`를 앱 루트에 붙이는 이유를 설명할 수 있다
- [ ] `@Query`와 `FetchDescriptor`의 차이를 말할 수 있다
- [ ] `context.insert` 후 왜 별도 `save()`가 없어도 되는지 설명할 수 있다
- [ ] 모델 프로퍼티를 바꾸면 왜 UI가 따라오는지 설명할 수 있다
- [ ] 관계 모델이 어디서 정의되는지 찾을 수 있다
- [ ] SwiftData와 UserDefaults, Keychain의 역할 차이를 말할 수 있다

## 이번 학습에서 내가 남길 정리
- SwiftData는 "저장" 자체보다 "모델과 UI를 어떻게 이어주는가"가 핵심이다.
- `TaskMaster`는 SwiftUI 때 봤던 프로젝트지만, SwiftData 관점으로 다시 읽으면 완전히 다른 프로젝트처럼 보인다.
- 다음 단계인 `Observation` 학습과도 직접 연결된다.  
  이유는 "데이터 변경이 어떻게 화면 상태로 이어지는가"를 더 명확히 보기 시작하기 때문이다.
