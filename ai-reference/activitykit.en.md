# ActivityKit AI Reference

> Live Activity and Dynamic Island implementation guide. Read this document to create Live Activities.

## Overview

ActivityKit is a framework for creating Live Activities that display real-time progress on the Lock Screen and Dynamic Island.
It's suitable for **ongoing tasks** such as delivery tracking, sports games, and timers.

## Required Imports

```swift
import ActivityKit
import WidgetKit
import SwiftUI
```

## Core Components

### 1. ActivityAttributes (Data Model)

```swift
struct DeliveryAttributes: ActivityAttributes {
    // Static data (set when Activity is created, cannot be changed)
    let orderNumber: String
    let restaurantName: String
    
    // Dynamic data (can be updated)
    struct ContentState: Codable, Hashable {
        let status: DeliveryStatus
        let estimatedArrival: Date
        let driverName: String?
    }
}

enum DeliveryStatus: String, Codable {
    case ordered = "Order Placed"
    case preparing = "Preparing"
    case pickedUp = "Picked Up"
    case delivering = "On the Way"
    case delivered = "Delivered"
}
```

### 2. Live Activity Widget

```swift
struct DeliveryLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: DeliveryAttributes.self) { context in
            // Lock Screen view
            LockScreenView(context: context)
        } dynamicIsland: { context in
            // Dynamic Island view
            DynamicIsland {
                // Expanded (long press)
                DynamicIslandExpandedRegion(.leading) {
                    Image(systemName: "bicycle")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(context.state.estimatedArrival, style: .timer)
                }
                DynamicIslandExpandedRegion(.center) {
                    Text(context.state.status.rawValue)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    ProgressView(value: 0.7)
                }
            } compactLeading: {
                // Compact left
                Image(systemName: "bicycle")
            } compactTrailing: {
                // Compact right
                Text(context.state.estimatedArrival, style: .timer)
            } minimal: {
                // Minimal (shown with other Activities)
                Image(systemName: "bicycle")
            }
        }
    }
}
```

### 3. Lock Screen View

```swift
struct LockScreenView: View {
    let context: ActivityViewContext<DeliveryAttributes>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "bicycle")
                    .foregroundStyle(.blue)
                Text(context.attributes.restaurantName)
                    .font(.headline)
                Spacer()
                Text(context.state.estimatedArrival, style: .timer)
                    .font(.title2.monospacedDigit())
            }
            
            Text(context.state.status.rawValue)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            ProgressView(value: progressValue)
                .tint(.blue)
        }
        .padding()
        .activityBackgroundTint(.black.opacity(0.8))
    }
    
    var progressValue: Double {
        switch context.state.status {
        case .ordered: return 0.2
        case .preparing: return 0.4
        case .pickedUp: return 0.6
        case .delivering: return 0.8
        case .delivered: return 1.0
        }
    }
}
```

## Complete Working Example

```swift
import ActivityKit
import SwiftUI

// MARK: - Attributes
struct DeliveryAttributes: ActivityAttributes {
    let orderNumber: String
    let restaurantName: String
    
    struct ContentState: Codable, Hashable {
        let status: String
        let remainingMinutes: Int
    }
}

// MARK: - Start Live Activity
func startDeliveryActivity() {
    // Check if supported
    guard ActivityAuthorizationInfo().areActivitiesEnabled else {
        print("Live Activity disabled")
        return
    }
    
    let attributes = DeliveryAttributes(
        orderNumber: "12345",
        restaurantName: "Delicious Pizza"
    )
    
    let initialState = DeliveryAttributes.ContentState(
        status: "Order Placed",
        remainingMinutes: 30
    )
    
    let content = ActivityContent(
        state: initialState,
        staleDate: Calendar.current.date(byAdding: .hour, value: 1, to: Date())
    )
    
    do {
        let activity = try Activity.request(
            attributes: attributes,
            content: content,
            pushType: nil  // Use .token for push updates
        )
        print("Activity started: \(activity.id)")
    } catch {
        print("Activity start failed: \(error)")
    }
}

// MARK: - Update Live Activity
func updateDeliveryActivity(activity: Activity<DeliveryAttributes>, newStatus: String, minutes: Int) async {
    let newState = DeliveryAttributes.ContentState(
        status: newStatus,
        remainingMinutes: minutes
    )
    
    let content = ActivityContent(state: newState, staleDate: nil)
    await activity.update(content)
}

// MARK: - End Live Activity
func endDeliveryActivity(activity: Activity<DeliveryAttributes>) async {
    let finalState = DeliveryAttributes.ContentState(
        status: "Delivered",
        remainingMinutes: 0
    )
    
    let content = ActivityContent(state: finalState, staleDate: nil)
    
    await activity.end(
        content,
        dismissalPolicy: .default  // Dismisses immediately. Can use .after(Date())
    )
}

// MARK: - Get All Activities
func getAllActivities() -> [Activity<DeliveryAttributes>] {
    return Activity<DeliveryAttributes>.activities
}
```

## Dynamic Island Layout

### Compact (Default State)

```swift
compactLeading: {
    // Left: Icon
    Image(systemName: "bicycle")
        .foregroundStyle(.blue)
} compactTrailing: {
    // Right: Key information
    Text("12 min")
        .font(.caption.monospacedDigit())
}
```

### Minimal (Shared with Other Activities)

```swift
minimal: {
    // Small circular area
    Image(systemName: "bicycle")
        .foregroundStyle(.blue)
}
```

### Expanded (Long Press)

```swift
DynamicIsland {
    DynamicIslandExpandedRegion(.leading) {
        VStack(alignment: .leading) {
            Image(systemName: "bicycle")
                .font(.title)
            Text("On the Way")
                .font(.caption)
        }
    }
    
    DynamicIslandExpandedRegion(.trailing) {
        VStack(alignment: .trailing) {
            Text("12 min")
                .font(.title2)
            Text("ETA")
                .font(.caption)
        }
    }
    
    DynamicIslandExpandedRegion(.center) {
        Text("Delicious Pizza")
            .font(.headline)
    }
    
    DynamicIslandExpandedRegion(.bottom) {
        // Progress bar, buttons, etc.
        ProgressView(value: 0.7)
        
        // Interactive button (iOS 17+)
        Button(intent: CallDriverIntent()) {
            Label("Call Driver", systemImage: "phone.fill")
        }
    }
}
```

## Info.plist Setup

```xml
<key>NSSupportsLiveActivities</key>
<true/>
<key>NSSupportsLiveActivitiesFrequentUpdates</key>
<true/>
```

## Push Updates

```swift
// Request push token when starting Activity
let activity = try Activity.request(
    attributes: attributes,
    content: content,
    pushType: .token
)

// Receive token
for await tokenData in activity.pushTokenUpdates {
    let token = tokenData.map { String(format: "%02x", $0) }.joined()
    // Send token to server
}
```

## Important Notes

1. **Time Limit**: Maximum 8 hours active, persists 4 hours after ending
2. **Widget Extension Required**: Live Activity is implemented in Widget Extension
3. **Dynamic Island**: Only supported on iPhone 14 Pro and later (Lock Screen works on all devices)
4. **Update Frequency**: System may throttle updates
5. **Background**: Can update via push even when app is in background

## File Structure

```
MyApp/
├── MyApp/
│   ├── MyApp.swift
│   └── ActivityManager.swift   # Activity management logic
└── MyWidgetExtension/
    ├── MyLiveActivity.swift    # Live Activity Widget
    └── DeliveryAttributes.swift # Shared model (shared with app)
```
