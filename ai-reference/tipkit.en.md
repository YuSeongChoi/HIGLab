# TipKit AI Reference

> Feature tips and onboarding guide. Read this document to generate TipKit code.

## Overview

TipKit is a framework that guides users about app features at the right moment.
The system automatically manages tip display conditions, frequency, and priority.

## Required Import

```swift
import TipKit
```

## App Setup

```swift
@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .task {
                    try? Tips.configure([
                        .displayFrequency(.immediate),  // or .daily, .weekly, .monthly
                        .datastoreLocation(.applicationDefault)
                    ])
                }
        }
    }
}
```

## Core Components

### 1. Basic Tip Definition

```swift
struct FavoriteTip: Tip {
    var title: Text {
        Text("Add to Favorites")
    }
    
    var message: Text? {
        Text("Tap the heart to add to your favorites")
    }
    
    var image: Image? {
        Image(systemName: "heart")
    }
}
```

### 2. Displaying Tips

```swift
struct ContentView: View {
    let favoriteTip = FavoriteTip()
    
    var body: some View {
        VStack {
            // Inline tip
            TipView(favoriteTip)
            
            Button {
                // Action
            } label: {
                Image(systemName: "heart")
            }
            // Popover tip
            .popoverTip(favoriteTip)
        }
    }
}
```

### 3. Invalidating Tips

```swift
struct FavoriteTip: Tip {
    // ...
}

// Close tip when user uses the feature
Button("Favorite") {
    FavoriteTip().invalidate(reason: .actionPerformed)
}

// Invalidation reasons
// .actionPerformed: User used the feature
// .displayCountExceeded: Display count exceeded
// .tipClosed: User closed the tip
```

## Complete Working Example

```swift
import SwiftUI
import TipKit

// MARK: - Tips Definition
struct SearchTip: Tip {
    var title: Text {
        Text("Search Feature")
    }
    
    var message: Text? {
        Text("Quickly find what you're looking for")
    }
    
    var image: Image? {
        Image(systemName: "magnifyingglass")
    }
}

struct FilterTip: Tip {
    // Set conditions with parameters
    @Parameter
    static var hasUsedSearch: Bool = false
    
    var title: Text {
        Text("Filter Feature")
    }
    
    var message: Text? {
        Text("Filter by category")
    }
    
    var image: Image? {
        Image(systemName: "line.3.horizontal.decrease.circle")
    }
    
    // Display condition: Only after using search
    var rules: [Rule] {
        #Rule(Self.$hasUsedSearch) { $0 == true }
    }
}

struct ShareTip: Tip {
    // Event-based conditions
    static let itemViewed = Event(id: "itemViewed")
    
    var title: Text {
        Text("Share")
    }
    
    var message: Text? {
        Text("Share with your friends")
    }
    
    var image: Image? {
        Image(systemName: "square.and.arrow.up")
    }
    
    // Only after viewing items 3+ times
    var rules: [Rule] {
        #Rule(Self.itemViewed) { $0.donations.count >= 3 }
    }
    
    // Display options
    var options: [TipOption] {
        MaxDisplayCount(3)  // Display maximum 3 times
    }
}

struct ProTip: Tip {
    var title: Text {
        Text("Pro Features ✨")
    }
    
    var message: Text? {
        Text("Explore more features")
    }
    
    // Action buttons
    var actions: [Action] {
        Action(id: "learn-more", title: "Learn More")
        Action(id: "dismiss", title: "Later", role: .cancel)
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
    @State private var items = ["Apple", "Banana", "Orange", "Grape", "Watermelon"]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Inline tip (top)
                TipView(proTip) { action in
                    if action.id == "learn-more" {
                        // Navigate to Pro page
                    }
                }
                .tipBackground(Color.blue.opacity(0.1))
                .padding()
                
                List {
                    ForEach(filteredItems, id: \.self) { item in
                        Text(item)
                            .onTapGesture {
                                // Record item view event
                                ShareTip.itemViewed.sendDonation()
                            }
                    }
                }
            }
            .navigationTitle("TipKit Demo")
            .searchable(text: $searchText, prompt: "Search")
            .onChange(of: searchText) { _, newValue in
                if !newValue.isEmpty {
                    // Record search usage
                    FilterTip.hasUsedSearch = true
                    searchTip.invalidate(reason: .actionPerformed)
                }
            }
            .toolbar {
                // Search button + popover tip
                Button {
                    // Focus search
                } label: {
                    Image(systemName: "magnifyingglass")
                }
                .popoverTip(searchTip)
                
                // Filter button + popover tip
                Button {
                    // Filter sheet
                } label: {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                }
                .popoverTip(filterTip)
                
                // Share button + popover tip
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

## Advanced Patterns

### 1. Combining Conditional Rules

```swift
struct AdvancedTip: Tip {
    @Parameter
    static var isLoggedIn: Bool = false
    
    @Parameter
    static var hasCompletedOnboarding: Bool = false
    
    static let featureUsed = Event(id: "featureUsed")
    
    var title: Text { Text("Advanced Feature") }
    
    var rules: [Rule] {
        // Logged in AND onboarding complete AND feature used 2+ times
        #Rule(Self.$isLoggedIn) { $0 == true }
        #Rule(Self.$hasCompletedOnboarding) { $0 == true }
        #Rule(Self.featureUsed) { $0.donations.count >= 2 }
    }
}
```

### 2. Date-based Conditions

```swift
struct DailyTip: Tip {
    static let appOpened = Event(id: "appOpened")
    
    var title: Text { Text("Tip of the Day") }
    
    var rules: [Rule] {
        // Only when app is opened today
        #Rule(Self.appOpened) {
            $0.donations.filter {
                Calendar.current.isDateInToday($0.date)
            }.count >= 1
        }
    }
}
```

### 3. Custom Styling

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

### 4. Debugging and Testing

```swift
// Reset all tips (for development)
try? Tips.resetDatastore()

// Force show specific tip
Tips.showAllTipsForTesting()

// Hide tips
Tips.hideAllTipsForTesting()

// Check tip status
if myTip.shouldDisplay {
    // Tip should be displayed
}
```

### 5. Tip Group Priority

```swift
struct HighPriorityTip: Tip {
    var title: Text { Text("Important Tip") }
    
    var options: [TipOption] {
        IgnoresDisplayFrequency(true)  // Ignore frequency limit
    }
}

struct LowPriorityTip: Tip {
    var title: Text { Text("General Tip") }
    
    var options: [TipOption] {
        MaxDisplayCount(1)  // Display only once
    }
}
```

## Important Notes

1. **Tips.configure() required**
   - Must be called once at app launch
   - Tips won't display without it

2. **displayFrequency settings**
   - `.immediate`: Immediately when conditions met
   - `.daily`: Once per day
   - `.weekly`: Once per week
   - `.monthly`: Once per month

3. **Data storage location**
   ```swift
   .datastoreLocation(.applicationDefault)  // Default
   .datastoreLocation(.groupContainer(identifier: "group.com.app"))  // App Group
   ```

4. **iOS 17+ only**
   - Not available on iOS 16 and earlier
   - Use conditional import or `@available`
