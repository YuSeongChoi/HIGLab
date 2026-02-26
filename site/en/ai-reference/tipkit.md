# TipKit AI Reference

> 기능 팁 및 온보딩 가이드. 이 문서를 읽고 TipKit 코드를 생성할 수 있습니다.

## 개요

TipKit은 앱의 기능을 사용자에게 적절한 시점에 안내하는 프레임워크입니다.
팁 표시 조건, 빈도, 우선순위를 시스템이 자동으로 관리합니다.

## 필수 Import

```swift
import TipKit
```

## 앱 설정

```swift
@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .task {
                    try? Tips.configure([
                        .displayFrequency(.immediate),  // 또는 .daily, .weekly, .monthly
                        .datastoreLocation(.applicationDefault)
                    ])
                }
        }
    }
}
```

## 핵심 구성요소

### 1. 기본 팁 정의

```swift
struct FavoriteTip: Tip {
    var title: Text {
        Text("즐겨찾기 추가")
    }
    
    var message: Text? {
        Text("하트를 탭해서 즐겨찾기에 추가하세요")
    }
    
    var image: Image? {
        Image(systemName: "heart")
    }
}
```

### 2. 팁 표시

```swift
struct ContentView: View {
    let favoriteTip = FavoriteTip()
    
    var body: some View {
        VStack {
            // 인라인 팁
            TipView(favoriteTip)
            
            Button {
                // 액션
            } label: {
                Image(systemName: "heart")
            }
            // 팝오버 팁
            .popoverTip(favoriteTip)
        }
    }
}
```

### 3. 팁 무효화

```swift
struct FavoriteTip: Tip {
    // ...
}

// 사용자가 기능 사용 시 팁 닫기
Button("즐겨찾기") {
    FavoriteTip().invalidate(reason: .actionPerformed)
}

// 무효화 이유
// .actionPerformed: 사용자가 기능 사용
// .displayCountExceeded: 표시 횟수 초과
// .tipClosed: 사용자가 팁 닫음
```

## 전체 작동 예제

```swift
import SwiftUI
import TipKit

// MARK: - Tips 정의
struct SearchTip: Tip {
    var title: Text {
        Text("검색 기능")
    }
    
    var message: Text? {
        Text("원하는 항목을 빠르게 찾아보세요")
    }
    
    var image: Image? {
        Image(systemName: "magnifyingglass")
    }
}

struct FilterTip: Tip {
    // 파라미터로 조건 설정
    @Parameter
    static var hasUsedSearch: Bool = false
    
    var title: Text {
        Text("필터 기능")
    }
    
    var message: Text? {
        Text("카테고리별로 필터링할 수 있어요")
    }
    
    var image: Image? {
        Image(systemName: "line.3.horizontal.decrease.circle")
    }
    
    // 표시 조건: 검색을 사용한 후에만
    var rules: [Rule] {
        #Rule(Self.$hasUsedSearch) { $0 == true }
    }
}

struct ShareTip: Tip {
    // 이벤트 기반 조건
    static let itemViewed = Event(id: "itemViewed")
    
    var title: Text {
        Text("공유하기")
    }
    
    var message: Text? {
        Text("친구에게 공유해보세요")
    }
    
    var image: Image? {
        Image(systemName: "square.and.arrow.up")
    }
    
    // 3번 이상 아이템을 본 후에만
    var rules: [Rule] {
        #Rule(Self.itemViewed) { $0.donations.count >= 3 }
    }
    
    // 표시 옵션
    var options: [TipOption] {
        MaxDisplayCount(3)  // 최대 3번만 표시
    }
}

struct ProTip: Tip {
    var title: Text {
        Text("Pro 기능 ✨")
    }
    
    var message: Text? {
        Text("더 많은 기능을 사용해보세요")
    }
    
    // 액션 버튼
    var actions: [Action] {
        Action(id: "learn-more", title: "자세히 보기")
        Action(id: "dismiss", title: "나중에", role: .cancel)
    }
}

// MARK: - App
@main
struct TipDemoApp: App {
    var body: some Scene {
        WindowGroup {
            TipDemoView()
                .task {
                    try? Tips.configure([
                        .displayFrequency(.immediate)
                    ])
                }
        }
    }
}

// MARK: - Views
struct TipDemoView: View {
    let searchTip = SearchTip()
    let filterTip = FilterTip()
    let shareTip = ShareTip()
    let proTip = ProTip()
    
    @State private var searchText = ""
    @State private var items = ["사과", "바나나", "오렌지", "포도", "수박"]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 인라인 팁 (상단)
                TipView(proTip) { action in
                    if action.id == "learn-more" {
                        // Pro 페이지로 이동
                    }
                }
                .tipBackground(Color.blue.opacity(0.1))
                .padding()
                
                List {
                    ForEach(filteredItems, id: \.self) { item in
                        Text(item)
                            .onTapGesture {
                                // 아이템 조회 이벤트 기록
                                ShareTip.itemViewed.sendDonation()
                            }
                    }
                }
            }
            .navigationTitle("TipKit 데모")
            .searchable(text: $searchText, prompt: "검색")
            .onChange(of: searchText) { _, newValue in
                if !newValue.isEmpty {
                    // 검색 사용 기록
                    FilterTip.hasUsedSearch = true
                    searchTip.invalidate(reason: .actionPerformed)
                }
            }
            .toolbar {
                // 검색 버튼 + 팝오버 팁
                Button {
                    // 검색 포커스
                } label: {
                    Image(systemName: "magnifyingglass")
                }
                .popoverTip(searchTip)
                
                // 필터 버튼 + 팝오버 팁
                Button {
                    // 필터 시트
                } label: {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                }
                .popoverTip(filterTip)
                
                // 공유 버튼 + 팝오버 팁
                Button {
                    shareTip.invalidate(reason: .actionPerformed)
                } label: {
                    Image(systemName: "square.and.arrow.up")
                }
                .popoverTip(shareTip)
            }
        }
    }
    
    var filteredItems: [String] {
        if searchText.isEmpty {
            return items
        }
        return items.filter { $0.contains(searchText) }
    }
}
```

## 고급 패턴

### 1. 조건부 규칙 조합

```swift
struct AdvancedTip: Tip {
    @Parameter
    static var isLoggedIn: Bool = false
    
    @Parameter
    static var hasCompletedOnboarding: Bool = false
    
    static let featureUsed = Event(id: "featureUsed")
    
    var title: Text { Text("고급 기능") }
    
    var rules: [Rule] {
        // 로그인 AND 온보딩 완료 AND 기능 2번 이상 사용
        #Rule(Self.$isLoggedIn) { $0 == true }
        #Rule(Self.$hasCompletedOnboarding) { $0 == true }
        #Rule(Self.featureUsed) { $0.donations.count >= 2 }
    }
}
```

### 2. 날짜 기반 조건

```swift
struct DailyTip: Tip {
    static let appOpened = Event(id: "appOpened")
    
    var title: Text { Text("오늘의 팁") }
    
    var rules: [Rule] {
        // 오늘 앱을 열었을 때만
        #Rule(Self.appOpened) {
            $0.donations.filter {
                Calendar.current.isDateInToday($0.date)
            }.count >= 1
        }
    }
}
```

### 3. 커스텀 스타일

```swift
struct StyledTipView: View {
    let tip: some Tip
    
    var body: some View {
        TipView(tip)
            .tipBackground(
                LinearGradient(
                    colors: [.blue.opacity(0.2), .purple.opacity(0.2)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .tipImageSize(CGSize(width: 40, height: 40))
            .tipCornerRadius(16)
    }
}
```

### 4. 디버깅 및 테스트

```swift
// 모든 팁 리셋 (개발용)
try? Tips.resetDatastore()

// 특정 팁 표시 강제
Tips.showAllTipsForTesting()

// 팁 숨기기
Tips.hideAllTipsForTesting()

// 팁 상태 확인
if myTip.shouldDisplay {
    // 팁이 표시되어야 함
}
```

### 5. 팁 그룹 우선순위

```swift
struct HighPriorityTip: Tip {
    var title: Text { Text("중요한 팁") }
    
    var options: [TipOption] {
        IgnoresDisplayFrequency(true)  // 빈도 제한 무시
    }
}

struct LowPriorityTip: Tip {
    var title: Text { Text("일반 팁") }
    
    var options: [TipOption] {
        MaxDisplayCount(1)  // 1번만 표시
    }
}
```

## 주의사항

1. **Tips.configure() 필수**
   - 앱 시작 시 한 번 호출
   - 미호출 시 팁이 표시되지 않음

2. **displayFrequency 설정**
   - `.immediate`: 조건 충족 시 즉시
   - `.daily`: 하루 1회
   - `.weekly`: 주 1회
   - `.monthly`: 월 1회

3. **데이터 저장 위치**
   ```swift
   .datastoreLocation(.applicationDefault)  // 기본
   .datastoreLocation(.groupContainer(identifier: "group.com.app"))  // App Group
   ```

4. **iOS 17+ 전용**
   - iOS 16 이하는 사용 불가
   - 조건부 import 또는 `@available` 사용
