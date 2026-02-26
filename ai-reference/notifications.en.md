# User Notifications AI Reference

> Push/Local notifications guide. Read this document to generate UserNotifications code.

## Overview

UserNotifications is a framework for managing local and remote notifications.
It supports notification scheduling, custom UI, action buttons, and more.

## Required Import

```swift
import UserNotifications
```

## Core Components

### 1. Request Permission

```swift
func requestPermission() async throws -> Bool {
    let center = UNUserNotificationCenter.current()
    
    let granted = try await center.requestAuthorization(options: [
        .alert,
        .badge,
        .sound,
        .criticalAlert,  // Critical alerts (requires separate approval)
        .provisional     // Quiet notifications (no permission required)
    ])
    
    return granted
}

// Check current permission status
func checkPermission() async -> UNAuthorizationStatus {
    let settings = await UNUserNotificationCenter.current().notificationSettings()
    return settings.authorizationStatus
}
```

### 2. Create Local Notification

```swift
func scheduleNotification() async throws {
    let content = UNMutableNotificationContent()
    content.title = "Notification Title"
    content.subtitle = "Subtitle"
    content.body = "Notification body text."
    content.sound = .default
    content.badge = 1
    
    // Trigger: after 5 seconds
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
    
    let request = UNNotificationRequest(
        identifier: UUID().uuidString,
        content: content,
        trigger: trigger
    )
    
    try await UNUserNotificationCenter.current().add(request)
}
```

### 3. Trigger Types

```swift
// Time interval (seconds)
let timeTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 60, repeats: true)

// Specific date/time
var dateComponents = DateComponents()
dateComponents.hour = 9
dateComponents.minute = 0
let calendarTrigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

// Location-based
let center = CLLocationCoordinate2D(latitude: 37.5665, longitude: 126.9780)
let region = CLCircularRegion(center: center, radius: 100, identifier: "office")
region.notifyOnEntry = true
let locationTrigger = UNLocationNotificationTrigger(region: region, repeats: false)
```

## Complete Working Example

```swift
import SwiftUI
import UserNotifications

// MARK: - Notification Manager
@Observable
class NotificationManager {
    var isAuthorized = false
    var pendingNotifications: [UNNotificationRequest] = []
    
    private let center = UNUserNotificationCenter.current()
    
    func requestPermission() async {
        do {
            isAuthorized = try await center.requestAuthorization(options: [.alert, .badge, .sound])
            await setupCategories()
        } catch {
            print("Permission request failed: \(error)")
        }
    }
    
    func checkStatus() async {
        let settings = await center.notificationSettings()
        isAuthorized = settings.authorizationStatus == .authorized
    }
    
    // Setup categories and actions
    private func setupCategories() async {
        let completeAction = UNNotificationAction(
            identifier: "COMPLETE",
            title: "Complete",
            options: [.foreground]
        )
        
        let snoozeAction = UNNotificationAction(
            identifier: "SNOOZE",
            title: "Remind in 10 minutes",
            options: []
        )
        
        let taskCategory = UNNotificationCategory(
            identifier: "TASK_REMINDER",
            actions: [completeAction, snoozeAction],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )
        
        center.setNotificationCategories([taskCategory])
    }
    
    // Schedule notification
    func scheduleReminder(title: String, body: String, date: Date) async throws {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.categoryIdentifier = "TASK_REMINDER"
        content.userInfo = ["taskId": UUID().uuidString]
        
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )
        
        try await center.add(request)
        await fetchPending()
    }
    
    // Daily repeating notification
    func scheduleDailyReminder(title: String, body: String, hour: Int, minute: Int) async throws {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: "daily-\(hour)-\(minute)",
            content: content,
            trigger: trigger
        )
        
        try await center.add(request)
    }
    
    // Fetch pending notifications
    func fetchPending() async {
        pendingNotifications = await center.pendingNotificationRequests()
    }
    
    // Cancel notification
    func cancel(identifier: String) {
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    func cancelAll() {
        center.removeAllPendingNotificationRequests()
    }
    
    // Clear badge
    func clearBadge() async {
        try? await center.setBadgeCount(0)
    }
}

// MARK: - View
struct NotificationDemoView: View {
    @State private var manager = NotificationManager()
    @State private var reminderTitle = ""
    @State private var reminderDate = Date().addingTimeInterval(60)
    
    var body: some View {
        NavigationStack {
            Form {
                // Permission section
                Section("Permission") {
                    HStack {
                        Text("Notification Permission")
                        Spacer()
                        Text(manager.isAuthorized ? "Granted" : "Denied")
                            .foregroundStyle(manager.isAuthorized ? .green : .red)
                    }
                    
                    if !manager.isAuthorized {
                        Button("Request Permission") {
                            Task { await manager.requestPermission() }
                        }
                    }
                }
                
                // Schedule notification
                Section("New Notification") {
                    TextField("Title", text: $reminderTitle)
                    DatePicker("Time", selection: $reminderDate, displayedComponents: [.date, .hourAndMinute])
                    
                    Button("Schedule Notification") {
                        Task {
                            try? await manager.scheduleReminder(
                                title: reminderTitle,
                                body: "Scheduled notification",
                                date: reminderDate
                            )
                            reminderTitle = ""
                        }
                    }
                    .disabled(reminderTitle.isEmpty)
                }
                
                // Pending notifications
                Section("Scheduled Notifications (\(manager.pendingNotifications.count))") {
                    ForEach(manager.pendingNotifications, id: \.identifier) { request in
                        VStack(alignment: .leading) {
                            Text(request.content.title)
                                .font(.headline)
                            if let trigger = request.trigger as? UNCalendarNotificationTrigger,
                               let nextDate = trigger.nextTriggerDate() {
                                Text(nextDate, style: .relative)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .swipeActions {
                            Button("Delete", role: .destructive) {
                                manager.cancel(identifier: request.identifier)
                                Task { await manager.fetchPending() }
                            }
                        }
                    }
                    
                    if !manager.pendingNotifications.isEmpty {
                        Button("Cancel All", role: .destructive) {
                            manager.cancelAll()
                            Task { await manager.fetchPending() }
                        }
                    }
                }
            }
            .navigationTitle("Notifications")
            .task {
                await manager.checkStatus()
                await manager.fetchPending()
            }
        }
    }
}

// MARK: - Handle Notifications in AppDelegate
class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }
    
    // Show notification when app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        return [.banner, .badge, .sound]
    }
    
    // Handle notification tap or action button
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        let userInfo = response.notification.request.content.userInfo
        let actionId = response.actionIdentifier
        
        switch actionId {
        case "COMPLETE":
            // Handle completion
            if let taskId = userInfo["taskId"] as? String {
                print("Task completed: \(taskId)")
            }
        case "SNOOZE":
            // Notify again in 10 minutes
            let content = response.notification.request.content.mutableCopy() as! UNMutableNotificationContent
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 600, repeats: false)
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            try? await center.add(request)
        default:
            break
        }
    }
}
```

## Advanced Patterns

### 1. Image Attachment

```swift
func scheduleWithImage(imageURL: URL) async throws {
    let content = UNMutableNotificationContent()
    content.title = "Photo Notification"
    content.body = "A new photo has arrived"
    
    let attachment = try UNNotificationAttachment(identifier: "image", url: imageURL, options: nil)
    content.attachments = [attachment]
    
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
    
    try await UNUserNotificationCenter.current().add(request)
}
```

### 2. Custom Notification UI (Notification Content Extension)

```swift
// NotificationViewController.swift (Extension Target)
import UIKit
import UserNotifications
import UserNotificationsUI

class NotificationViewController: UIViewController, UNNotificationContentExtension {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    func didReceive(_ notification: UNNotification) {
        let content = notification.request.content
        titleLabel.text = content.title
        
        if let attachment = content.attachments.first,
           attachment.url.startAccessingSecurityScopedResource() {
            imageView.image = UIImage(contentsOfFile: attachment.url.path)
            attachment.url.stopAccessingSecurityScopedResource()
        }
    }
}
```

### 3. Remote Push Notifications (APNs)

```swift
// AppDelegate
func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
    print("Device Token: \(token)")
    // Send token to server
}

func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    print("APNs registration failed: \(error)")
}

// Request registration
UIApplication.shared.registerForRemoteNotifications()
```

## Important Notes

1. **Permission Request Timing**
   - Don't request immediately on first launch ❌
   - Request right before using notification features ✅

2. **Notification Identifiers**
   - Registering with the same identifier overwrites existing notification
   - Use this for updatable notifications

3. **Badge Management**
   ```swift
   // Set badge
   try await center.setBadgeCount(5)
   
   // Clear badge (when app opens)
   try await center.setBadgeCount(0)
   ```

4. **Simulator Limitations**
   - Remote push notifications only testable on real devices
   - Local notifications work on simulator
