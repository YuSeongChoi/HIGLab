# SiriTodo - AppIntents 샘플 프로젝트

Siri 및 단축어와 연동되는 할일 관리 앱 샘플입니다.  
iOS 16+ / macOS 13+의 **AppIntents** 프레임워크를 활용합니다.

## 🎯 주요 기능

- **Siri 음성 명령**: "할일에 장보기 추가해줘"
- **단축어 앱 연동**: 자동화 및 위젯에서 사용 가능
- **앱 내 할일 관리**: 추가, 완료, 삭제

## 📁 프로젝트 구조

```
SiriTodo/
├── Shared/
│   ├── TodoItem.swift      # 할일 모델 (AppEntity 준수)
│   └── TodoStore.swift     # 데이터 저장소 (싱글톤)
├── SiriTodoApp/
│   ├── SiriTodoApp.swift   # @main 진입점
│   ├── ContentView.swift   # 메인 목록 화면
│   └── AddTodoView.swift   # 할일 추가 시트
├── Intents/
│   ├── AddTodoIntent.swift      # 할일 추가 인텐트
│   ├── ListTodosIntent.swift    # 목록 조회 인텐트
│   ├── CompleteTodoIntent.swift # 완료 처리 인텐트
│   └── AppShortcuts.swift       # Siri 단축어 정의
└── README.md
```

## 🗣️ Siri 명령어 예시

| 기능 | 명령어 예시 |
|------|------------|
| 할일 추가 | "할일에 장보기 추가해줘" |
| 목록 보기 | "할일 목록 보여줘" |
| 완료 처리 | "장보기 완료해줘" |
| 빠른 완료 | "다음 할일 완료" |

## 🔧 핵심 개념

### AppIntent
```swift
struct AddTodoIntent: AppIntent {
    static var title: LocalizedStringResource = "할일 추가"
    
    @Parameter(title: "할일 제목")
    var title: String
    
    func perform() async throws -> some IntentResult {
        // 실행 로직
    }
}
```

### AppEntity
```swift
extension TodoItem: AppEntity {
    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        TypeDisplayRepresentation(name: "할일")
    }
    
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(title)")
    }
}
```

### AppShortcutsProvider
```swift
struct SiriTodoShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: AddTodoIntent(),
            phrases: ["할일에 \(\.$title) 추가해줘"],
            shortTitle: "할일 추가"
        )
    }
}
```

## 🚀 시작하기

### 1. Xcode 프로젝트 생성
1. Xcode에서 새 프로젝트 생성 (App 템플릿)
2. 이 폴더의 파일들을 프로젝트에 추가

### 2. 앱 그룹 설정 (선택)
위젯이나 앱 확장과 데이터 공유가 필요한 경우:
1. Signing & Capabilities에서 App Groups 추가
2. `TodoStore.swift`의 UserDefaults 코드 수정

### 3. 빌드 및 실행
- 시뮬레이터 또는 실제 기기에서 실행
- 단축어 앱에서 "SiriTodo" 검색하여 확인

## 📚 참고 자료

- [App Intents - Apple Developer](https://developer.apple.com/documentation/appintents)
- [Siri and Shortcuts - HIG](https://developer.apple.com/design/human-interface-guidelines/siri)
- [WWDC22: Dive into App Intents](https://developer.apple.com/videos/play/wwdc2022/10032/)

## ⚠️ 요구 사항

- iOS 16.0+ / macOS 13.0+
- Xcode 14.0+
- Swift 5.7+

## 📝 라이선스

MIT License - 학습 및 참고용 샘플 코드
