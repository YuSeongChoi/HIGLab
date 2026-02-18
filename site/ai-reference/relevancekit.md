# RelevanceKit AI Reference

> 맥락 기반 관련성 판단 가이드. 이 문서를 읽고 RelevanceKit 코드를 생성할 수 있습니다.

## 개요

RelevanceKit은 iOS 18+에서 제공하는 Apple Intelligence 기반 프레임워크입니다.
사용자의 현재 맥락(시간, 위치, 활동 등)에 따라 콘텐츠의 관련성을 판단하고,
가장 적절한 정보를 적시에 표시할 수 있도록 도와줍니다.

## 필수 Import

```swift
import RelevanceKit
```

## 프로젝트 설정

### Info.plist

```xml
<!-- 위치 (선택적) -->
<key>NSLocationWhenInUseUsageDescription</key>
<string>맥락 기반 추천을 위해 위치 정보가 필요합니다.</string>

<!-- 모션 (선택적) -->
<key>NSMotionUsageDescription</key>
<string>활동 상태를 파악하기 위해 모션 데이터가 필요합니다.</string>
```

## 핵심 구성요소

### 1. RelevanceEngine

```swift
import RelevanceKit

// 관련성 엔진
let engine = RelevanceEngine.shared

// 현재 맥락 가져오기
let context = await engine.currentContext()
```

### 2. RelevanceContext (맥락 정보)

```swift
// 현재 맥락
let context = await engine.currentContext()

context.timeOfDay       // .morning, .afternoon, .evening, .night
context.dayOfWeek       // .weekday, .weekend
context.activity        // .stationary, .walking, .driving, .workout
context.location        // 위치 유형 (.home, .work, .commuting, .unknown)
context.deviceUsage     // .active, .passive
context.focus           // 현재 집중 모드
```

### 3. RelevanceScore (관련성 점수)

```swift
// 항목의 관련성 점수 계산
let items: [ContentItem] = [...]

let rankedItems = await engine.rank(items) { item in
    // 각 항목에 대한 관련성 힌트 제공
    RelevanceHints(
        category: item.category,
        timeRelevance: item.scheduledTime,
        locationRelevance: item.location
    )
}

// 점수별 정렬된 결과
for (item, score) in rankedItems {
    print("\(item.title): \(score.value)")  // 0.0 ~ 1.0
}
```

## 전체 작동 예제

```swift
import SwiftUI
import RelevanceKit

// MARK: - Content Item
struct ContentItem: Identifiable {
    let id = UUID()
    let title: String
    let category: ContentCategory
    let scheduledTime: Date?
    let location: ContentLocation?
    let priority: Int
}

enum ContentCategory: String, CaseIterable {
    case work = "업무"
    case personal = "개인"
    case health = "건강"
    case entertainment = "엔터테인먼트"
    case shopping = "쇼핑"
}

struct ContentLocation {
    let type: LocationType
    let name: String
    
    enum LocationType {
        case home, work, gym, store, restaurant
    }
}

// MARK: - Relevance Manager
@Observable
class RelevanceManager {
    var currentContext: RelevanceContext?
    var rankedItems: [(ContentItem, RelevanceScore)] = []
    var isLoading = false
    
    private let engine = RelevanceEngine.shared
    
    var isSupported: Bool {
        RelevanceEngine.isSupported
    }
    
    var contextSummary: String {
        guard let context = currentContext else { return "로딩 중..." }
        
        var parts: [String] = []
        
        switch context.timeOfDay {
        case .morning: parts.append("🌅 아침")
        case .afternoon: parts.append("☀️ 오후")
        case .evening: parts.append("🌆 저녁")
        case .night: parts.append("🌙 밤")
        }
        
        switch context.activity {
        case .stationary: parts.append("정지")
        case .walking: parts.append("🚶 걷는 중")
        case .driving: parts.append("🚗 운전 중")
        case .workout: parts.append("🏃 운동 중")
        default: break
        }
        
        switch context.location {
        case .home: parts.append("🏠 집")
        case .work: parts.append("🏢 직장")
        case .commuting: parts.append("🚌 이동 중")
        default: break
        }
        
        return parts.joined(separator: " • ")
    }
    
    func fetchContext() async {
        currentContext = await engine.currentContext()
    }
    
    func rankItems(_ items: [ContentItem]) async {
        isLoading = true
        
        rankedItems = await engine.rank(items) { item in
            buildHints(for: item)
        }
        
        isLoading = false
    }
    
    private func buildHints(for item: ContentItem) -> RelevanceHints {
        var hints = RelevanceHints()
        
        // 카테고리 기반 힌트
        switch item.category {
        case .work:
            hints.preferredContext = [.weekday, .work]
            hints.preferredTimeOfDay = [.morning, .afternoon]
        case .personal:
            hints.preferredContext = [.weekend, .home]
        case .health:
            hints.preferredActivity = [.stationary, .walking]
            hints.preferredTimeOfDay = [.morning, .evening]
        case .entertainment:
            hints.preferredContext = [.home]
            hints.preferredTimeOfDay = [.evening, .night]
        case .shopping:
            hints.preferredActivity = [.walking]
        }
        
        // 시간 기반 힌트
        if let scheduledTime = item.scheduledTime {
            hints.timeRelevance = scheduledTime
        }
        
        // 위치 기반 힌트
        if let location = item.location {
            switch location.type {
            case .home: hints.preferredContext.insert(.home)
            case .work: hints.preferredContext.insert(.work)
            case .gym: hints.preferredActivity.insert(.workout)
            default: break
            }
        }
        
        return hints
    }
}

// MARK: - Main View
struct RelevanceView: View {
    @State private var manager = RelevanceManager()
    
    let sampleItems: [ContentItem] = [
        ContentItem(title: "팀 미팅 준비", category: .work, scheduledTime: nil, location: ContentLocation(type: .work, name: "회사"), priority: 1),
        ContentItem(title: "운동하기", category: .health, scheduledTime: nil, location: ContentLocation(type: .gym, name: "헬스장"), priority: 2),
        ContentItem(title: "넷플릭스 보기", category: .entertainment, scheduledTime: nil, location: ContentLocation(type: .home, name: "집"), priority: 3),
        ContentItem(title: "장보기", category: .shopping, scheduledTime: nil, location: ContentLocation(type: .store, name: "마트"), priority: 4),
        ContentItem(title: "독서", category: .personal, scheduledTime: nil, location: nil, priority: 5),
        ContentItem(title: "이메일 확인", category: .work, scheduledTime: nil, location: nil, priority: 6),
        ContentItem(title: "명상", category: .health, scheduledTime: nil, location: ContentLocation(type: .home, name: "집"), priority: 7),
    ]
    
    var body: some View {
        NavigationStack {
            List {
                // 현재 맥락
                Section("현재 맥락") {
                    if !manager.isSupported {
                        Label("이 기기에서 지원되지 않습니다", systemImage: "exclamationmark.triangle")
                            .foregroundStyle(.orange)
                    } else {
                        HStack {
                            Image(systemName: "sparkles")
                                .foregroundStyle(.purple)
                            Text(manager.contextSummary)
                        }
                    }
                }
                
                // 관련성 순위
                Section("추천 순서") {
                    if manager.isLoading {
                        ProgressView()
                    } else if manager.rankedItems.isEmpty {
                        Text("항목을 분석하려면 새로고침하세요")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(Array(manager.rankedItems.enumerated()), id: \.1.0.id) { index, pair in
                            let (item, score) = pair
                            RankedItemRow(
                                rank: index + 1,
                                item: item,
                                score: score
                            )
                        }
                    }
                }
                
                // 설명
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("AI 기반 추천", systemImage: "brain")
                            .font(.subheadline.bold())
                        
                        Text("현재 시간, 위치, 활동 상태를 분석하여 가장 관련성 높은 항목을 상위에 표시합니다.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("RelevanceKit")
            .refreshable {
                await manager.fetchContext()
                await manager.rankItems(sampleItems)
            }
            .task {
                await manager.fetchContext()
                await manager.rankItems(sampleItems)
            }
        }
    }
}

// MARK: - Ranked Item Row
struct RankedItemRow: View {
    let rank: Int
    let item: ContentItem
    let score: RelevanceScore
    
    var body: some View {
        HStack(spacing: 12) {
            // 순위
            Text("\(rank)")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(width: 28, height: 28)
                .background(rankColor, in: Circle())
            
            // 아이템 정보
            VStack(alignment: .leading, spacing: 2) {
                Text(item.title)
                    .font(.headline)
                
                HStack {
                    Text(item.category.rawValue)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    if let location = item.location {
                        Text("• \(location.name)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            Spacer()
            
            // 관련성 점수
            VStack(alignment: .trailing) {
                Text("\(Int(score.value * 100))%")
                    .font(.headline)
                    .foregroundStyle(scoreColor)
                
                Text("관련성")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
    
    var rankColor: Color {
        switch rank {
        case 1: return .yellow
        case 2: return .gray
        case 3: return .orange
        default: return .blue.opacity(0.7)
        }
    }
    
    var scoreColor: Color {
        if score.value >= 0.8 { return .green }
        if score.value >= 0.5 { return .orange }
        return .red
    }
}

#Preview {
    RelevanceView()
}
```

## 고급 패턴

### 1. 위젯 관련성 최적화

```swift
import WidgetKit
import RelevanceKit

struct RelevantContentWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: "RelevantContent",
            provider: RelevantTimelineProvider()
        ) { entry in
            RelevantWidgetView(entry: entry)
        }
        .configurationDisplayName("스마트 추천")
        .description("현재 상황에 맞는 콘텐츠를 표시합니다")
    }
}

struct RelevantTimelineProvider: TimelineProvider {
    func getTimeline(in context: Context, completion: @escaping (Timeline<RelevantEntry>) -> Void) {
        Task {
            let engine = RelevanceEngine.shared
            let currentContext = await engine.currentContext()
            
            // 맥락에 따른 콘텐츠 선택
            let relevantItem = await selectMostRelevantItem(for: currentContext)
            
            let entry = RelevantEntry(date: Date(), item: relevantItem)
            
            // 맥락 변화 예상 시점에 새로고침
            let refreshDate = calculateNextContextChange(from: currentContext)
            let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
            
            completion(timeline)
        }
    }
}
```

### 2. 알림 타이밍 최적화

```swift
import UserNotifications
import RelevanceKit

class SmartNotificationManager {
    let engine = RelevanceEngine.shared
    
    func scheduleSmartNotification(
        title: String,
        body: String,
        preferredTime: Date,
        category: ContentCategory
    ) async {
        let context = await engine.currentContext()
        
        // 최적의 알림 시간 계산
        let optimalTime = await engine.suggestOptimalTime(
            for: preferredTime,
            hints: RelevanceHints(
                category: category,
                preferredContext: contextFor(category)
            )
        )
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: optimalTime.timeIntervalSinceNow,
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )
        
        try? await UNUserNotificationCenter.current().add(request)
    }
    
    private func contextFor(_ category: ContentCategory) -> Set<ContextType> {
        switch category {
        case .work: return [.weekday, .work]
        case .health: return [.morning, .evening]
        case .entertainment: return [.evening, .home]
        default: return []
        }
    }
}
```

### 3. 검색 결과 재정렬

```swift
struct SmartSearchView: View {
    @State private var searchText = ""
    @State private var results: [SearchResult] = []
    @State private var rankedResults: [(SearchResult, RelevanceScore)] = []
    
    let engine = RelevanceEngine.shared
    
    var body: some View {
        List(rankedResults, id: \.0.id) { result, score in
            HStack {
                Text(result.title)
                Spacer()
                Text("\(Int(score.value * 100))%")
                    .foregroundStyle(.secondary)
            }
        }
        .searchable(text: $searchText)
        .onChange(of: searchText) { _, query in
            Task {
                results = await search(query)
                rankedResults = await rerankResults(results)
            }
        }
    }
    
    func rerankResults(_ results: [SearchResult]) async -> [(SearchResult, RelevanceScore)] {
        await engine.rank(results) { result in
            RelevanceHints(
                category: result.category,
                recency: result.lastAccessed,
                frequency: result.accessCount
            )
        }
    }
}
```

## 주의사항

1. **iOS 버전**
   - RelevanceKit: iOS 18+ 및 Apple Silicon 필요
   - Apple Intelligence 기능

2. **개인정보**
   - 모든 분석은 온디바이스
   - 사용자 데이터 서버 전송 없음

3. **배터리 고려**
   - 맥락 분석은 리소스 소모
   - 불필요한 빈번한 호출 자제

4. **폴백 제공**
   - 미지원 기기에서는 기본 정렬 사용
   - `isSupported` 확인 필수

5. **정확도**
   - 초기에는 학습 데이터 부족
   - 사용 시간에 따라 정확도 향상
