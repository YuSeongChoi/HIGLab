# TaskMaster

**SwiftData** 기반 할일 관리 앱 샘플 프로젝트

iOS 17+에서 도입된 SwiftData 프레임워크를 활용하여 데이터 영속성을 구현하는 방법을 보여줍니다.

## 📱 스크린샷

| 메인 화면 | 추가 화면 | 상세 화면 |
|:---:|:---:|:---:|
| 필터, 검색, 카테고리 | 마감일, 우선순위 | 편집, 삭제 |

## ✨ 주요 기능

- **할일 관리**: 생성, 조회, 수정, 삭제 (CRUD)
- **카테고리**: 할일 분류 및 필터링
- **우선순위**: 4단계 우선순위 설정
- **마감일**: 날짜/시간 설정, 마감 임박/지남 표시
- **검색**: 제목 기반 검색
- **필터**: 전체/미완료/완료 필터링

## 🗂 파일 구조

```
TaskMaster/
├── README.md
├── Shared/                          # 공유 모델 & 서비스
│   ├── TaskItem.swift               # @Model - 할일 데이터 모델
│   ├── Category.swift               # @Model - 카테고리 모델 (관계)
│   └── DataService.swift            # CRUD 헬퍼 서비스
│
└── TaskMasterApp/                   # 메인 앱
    ├── TaskMasterApp.swift          # @main - ModelContainer 설정
    ├── ContentView.swift            # 메인 리스트 뷰
    ├── TaskRowView.swift            # 개별 할일 Row
    ├── AddTaskView.swift            # 새 할일 추가 Sheet
    └── TaskDetailView.swift         # 상세/편집 뷰
```

## 🔑 핵심 개념

### SwiftData 모델 정의

```swift
import SwiftData

@Model
final class TaskItem {
    var title: String
    var isCompleted: Bool
    var dueDate: Date?
    var priority: Int
    
    // 관계 설정
    @Relationship(inverse: \Category.tasks)
    var category: Category?
}
```

### ModelContainer 설정

```swift
@main
struct TaskMasterApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([TaskItem.self, Category.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        return try! ModelContainer(for: schema, configurations: [config])
    }()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
```

### @Query로 데이터 조회

```swift
struct ContentView: View {
    @Query(sort: \TaskItem.createdAt, order: .reverse)
    private var tasks: [TaskItem]
    
    var body: some View {
        List(tasks) { task in
            TaskRowView(task: task)
        }
    }
}
```

### @Bindable로 양방향 바인딩

```swift
struct TaskDetailView: View {
    @Bindable var task: TaskItem
    
    var body: some View {
        TextField("제목", text: $task.title)  // 자동 저장
    }
}
```

## 🎨 HIG 적용 사항

### 데이터 영속성
- **자동 저장**: SwiftData가 변경사항을 자동으로 저장
- **안정적인 동기화**: 앱 재시작 시에도 데이터 유지
- **관계 무결성**: 삭제 시 관계 자동 정리 (`nullify`)

### 사용자 경험
- **즉각적인 피드백**: 체크 시 애니메이션
- **되돌리기 가능**: 스와이프로 완료/삭제
- **빈 상태 처리**: ContentUnavailableView 활용

### 리스트 인터랙션
- **스와이프 액션**: 좌우 스와이프로 완료/삭제
- **검색**: 네비게이션 바 검색
- **필터 칩**: 카테고리 빠른 전환

## 📋 요구사항

- **iOS**: 17.0+
- **Xcode**: 15.0+
- **Swift**: 5.9+

## 🚀 사용법

1. Xcode에서 새 프로젝트 생성 (iOS App)
2. 파일들을 해당 위치에 복사
3. 빌드 & 실행

### 프리뷰 확인

각 뷰 파일에 `#Preview` 매크로가 포함되어 있어 Xcode Canvas에서 바로 확인 가능합니다.

```swift
#Preview {
    ContentView()
        .modelContainer(.preview)  // 인메모리 샘플 데이터
}
```

## 🔗 참고 자료

- [SwiftData Documentation](https://developer.apple.com/documentation/swiftdata)
- [WWDC23: Meet SwiftData](https://developer.apple.com/videos/play/wwdc2023/10187/)
- [WWDC23: Model your schema with SwiftData](https://developer.apple.com/videos/play/wwdc2023/10195/)
- [HIG: Data Entry](https://developer.apple.com/design/human-interface-guidelines/data-entry)

## 📝 라이선스

MIT License - 학습 및 참고 목적으로 자유롭게 사용하세요.
