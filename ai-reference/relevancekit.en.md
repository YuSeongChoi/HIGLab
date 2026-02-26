# RelevanceKit AI Reference

> Context-based relevance determination guide. You can generate RelevanceKit code by reading this document.

## Overview

RelevanceKit is an Apple Intelligence-based framework available in iOS 18+.
It helps determine content relevance based on the user's current context (time, location, activity, etc.) to display the most appropriate information at the right time.

## Required Import

```swift
import RelevanceKit
```

## Project Setup

### Info.plist

```xml
<!-- Location (optional) -->
<key>NSLocationWhenInUseUsageDescription</key>
<string>Location information is needed for context-based recommendations.</string>

<!-- Motion (optional) -->
<key>NSMotionUsageDescription</key>
<string>Motion data is needed to determine activity status.</string>
```

## Core Components

### 1. RelevanceEngine

```swift
import RelevanceKit

// Relevance engine
let engine = RelevanceEngine.shared

// Get current context
let context = await engine.currentContext()
```

### 2. RelevanceContext (Context Information)

```swift
// Current context
let context = await engine.currentContext()

context.timeOfDay       // .morning, .afternoon, .evening, .night
context.dayOfWeek       // .weekday, .weekend
context.activity        // .stationary, .walking, .driving, .workout
context.location        // Location type (.home, .work, .commuting, .unknown)
context.deviceUsage     // .active, .passive
context.focus           // Current focus mode
```

### 3. RelevanceScore

```swift
// Calculate relevance score for items
let items: [ContentItem] = [...]

let rankedItems = await engine.rank(items) { item in
    // Provide relevance hints for each item
    RelevanceHints(
        category: item.category,
        timeRelevance: item.scheduledTime,
        locationRelevance: item.location
    )
}

// Results sorted by score
for (item, score) in rankedItems {
    print("\(item.title): \(score.value)")  // 0.0 ~ 1.0
}
```

## Complete Working Example

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
    case work = "Work"
    case personal = "Personal"
    case health = "Health"
    case entertainment = "Entertainment"
    case shopping = "Shopping"
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
        guard let context = currentContext else { return "Loading..." }
        
        var parts: [String] = []
        
        switch context.timeOfDay {
        case .morning: parts.append("🌅 Morning")
        case .afternoon: parts.append("☀️ Afternoon")
        case .evening: parts.append("🌆 Evening")
        case .night: parts.append("🌙 Night")
        }
        
        switch context.activity {
        case .stationary: parts.append("Stationary")
        case .walking: parts.append("🚶 Walking")
        case .driving: parts.append("🚗 Driving")
        case .workout: parts.append("🏃 Working Out")
        default: break
        }
        
        switch context.location {
        case .home: parts.append("🏠 Home")
        case .work: parts.append("🏢 Work")
        case .commuting: parts.append("🚌 Commuting")
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
        
        // Category-based hints
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
        
        // Time-based hints
        if let scheduledTime = item.scheduledTime {
            hints.timeRelevance = scheduledTime
        }
        
        // Location-based hints
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
        ContentItem(title: "Team Meeting Prep", category: .work, scheduledTime: nil, location: ContentLocation(type: .work, name: "Office"), priority: 1),
        ContentItem(title: "Exercise", category: .health, scheduledTime: nil, location: ContentLocation(type: .gym, name: "Gym"), priority: 2),
        ContentItem(title: "Watch Netflix", category: .entertainment, scheduledTime: nil, location: ContentLocation(type: .home, name: "Home"), priority: 3),
        ContentItem(title: "Grocery Shopping", category: .shopping, scheduledTime: nil, location: ContentLocation(type: .store, name: "Store"), priority: 4),
        ContentItem(title: "Reading", category: .personal, scheduledTime: nil, location: nil, priority: 5),
        ContentItem(title: "Check Email", category: .work, scheduledTime: nil, location: nil, priority: 6),
        ContentItem(title: "Meditation", category: .health, scheduledTime: nil, location: ContentLocation(type: .home, name: "Home"), priority: 7),
    ]
    
    var body: some View {
        NavigationStack {
            List {
                // Current context
                Section("Current Context") {
                    if !manager.isSupported {
                        Label("Not supported on this device", systemImage: "exclamationmark.triangle")
                            .foregroundStyle(.orange)
                    } else {
                        HStack {
                            Image(systemName: "sparkles")
                                .foregroundStyle(.purple)
                            Text(manager.contextSummary)
                        }
                    }
                }
                
                // Relevance ranking
                Section("Recommended Order") {
                    if manager.isLoading {
                        ProgressView()
                    } else if manager.rankedItems.isEmpty {
                        Text("Refresh to analyze items")
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
                
                // Explanation
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("AI-Based Recommendations", systemImage: "brain")
                            .font(.subheadline.bold())
                        
                        Text("Analyzes current time, location, and activity status to display the most relevant items at the top.")
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
            // Rank
            Text("\(rank)")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(width: 28, height: 28)
                .background(rankColor, in: Circle())
            
            // Item info
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
            
            // Relevance score
            VStack(alignment: .trailing) {
                Text("\(Int(score.value * 100))%")
                    .font(.headline)
                    .foregroundStyle(scoreColor)
                
                Text("Relevance")
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

## Advanced Patterns

### 1. Widget Relevance Optimization

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
        .configurationDisplayName("Smart Recommendations")
        .description("Displays content relevant to your current situation")
    }
}

struct RelevantTimelineProvider: TimelineProvider {
    func getTimeline(in context: Context, completion: @escaping (Timeline<RelevantEntry>) -> Void) {
        Task {
            let engine = RelevanceEngine.shared
            let currentContext = await engine.currentContext()
            
            // Select content based on context
            let relevantItem = await selectMostRelevantItem(for: currentContext)
            
            let entry = RelevantEntry(date: Date(), item: relevantItem)
            
            // Refresh at expected context change time
            let refreshDate = calculateNextContextChange(from: currentContext)
            let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
            
            completion(timeline)
        }
    }
}
```

### 2. Notification Timing Optimization

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
        
        // Calculate optimal notification time
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

### 3. Search Result Reranking

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

## Notes

1. **iOS Version**
   - RelevanceKit: iOS 18+ and Apple Silicon required
   - Part of Apple Intelligence features

2. **Privacy**
   - All analysis is on-device
   - No user data sent to servers

3. **Battery Consideration**
   - Context analysis consumes resources
   - Avoid unnecessary frequent calls

4. **Provide Fallback**
   - Use default sorting on unsupported devices
   - Always check `isSupported`

5. **Accuracy**
   - Initially lacks learning data
   - Accuracy improves over time with usage
