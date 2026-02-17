# User Notifications AI Reference

> 푸시/로컬 알림 가이드. 이 문서를 읽고 UserNotifications 코드를 생성할 수 있습니다.

## 개요

UserNotifications는 로컬 및 원격 알림을 관리하는 프레임워크입니다.
알림 예약, 커스텀 UI, 액션 버튼 등을 지원합니다.

## 필수 Import

```swift
import UserNotifications
```

## 핵심 구성요소

### 1. 권한 요청

```swift
func requestPermission() async throws -> Bool {
    let center = UNUserNotificationCenter.current()
    
    let granted = try await center.requestAuthorization(options: [
        .alert,
        .badge,
        .sound,
        .criticalAlert,  // 긴급 알림 (별도 승인 필요)
        .provisional     // 조용한 알림 (권한 없이 가능)
    ])
    
    return granted
}

// 현재 권한 상태 확인
func checkPermission() async -> UNAuthorizationStatus {
    let settings = await UNUserNotificationCenter.current().notificationSettings()
    return settings.authorizationStatus
}
```

### 2. 로컬 알림 생성

```swift
func scheduleNotification() async throws {
    let content = UNMutableNotificationContent()
    content.title = "알림 제목"
    content.subtitle = "부제목"
    content.body = "알림 내용입니다."
    content.sound = .default
    content.badge = 1
    
    // 트리거: 5초 후
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
    
    let request = UNNotificationRequest(
        identifier: UUID().uuidString,
        content: content,
        trigger: trigger
    )
    
    try await UNUserNotificationCenter.current().add(request)
}
```

### 3. 트리거 종류

```swift
// 시간 간격 (초)
let timeTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 60, repeats: true)

// 특정 날짜/시간
var dateComponents = DateComponents()
dateComponents.hour = 9
dateComponents.minute = 0
let calendarTrigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

// 위치 기반
let center = CLLocationCoordinate2D(latitude: 37.5665, longitude: 126.9780)
let region = CLCircularRegion(center: center, radius: 100, identifier: "office")
region.notifyOnEntry = true
let locationTrigger = UNLocationNotificationTrigger(region: region, repeats: false)
```

## 전체 작동 예제

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
            print("권한 요청 실패: \(error)")
        }
    }
    
    func checkStatus() async {
        let settings = await center.notificationSettings()
        isAuthorized = settings.authorizationStatus == .authorized
    }
    
    // 카테고리 및 액션 설정
    private func setupCategories() async {
        let completeAction = UNNotificationAction(
            identifier: "COMPLETE",
            title: "완료",
            options: [.foreground]
        )
        
        let snoozeAction = UNNotificationAction(
            identifier: "SNOOZE",
            title: "10분 뒤 알림",
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
    
    // 알림 예약
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
    
    // 매일 반복 알림
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
    
    // 대기 중인 알림 조회
    func fetchPending() async {
        pendingNotifications = await center.pendingNotificationRequests()
    }
    
    // 알림 취소
    func cancel(identifier: String) {
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    func cancelAll() {
        center.removeAllPendingNotificationRequests()
    }
    
    // 배지 초기화
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
                // 권한 섹션
                Section("권한") {
                    HStack {
                        Text("알림 권한")
                        Spacer()
                        Text(manager.isAuthorized ? "허용됨" : "거부됨")
                            .foregroundStyle(manager.isAuthorized ? .green : .red)
                    }
                    
                    if !manager.isAuthorized {
                        Button("권한 요청") {
                            Task { await manager.requestPermission() }
                        }
                    }
                }
                
                // 알림 예약
                Section("새 알림") {
                    TextField("제목", text: $reminderTitle)
                    DatePicker("시간", selection: $reminderDate, displayedComponents: [.date, .hourAndMinute])
                    
                    Button("알림 예약") {
                        Task {
                            try? await manager.scheduleReminder(
                                title: reminderTitle,
                                body: "예약된 알림입니다",
                                date: reminderDate
                            )
                            reminderTitle = ""
                        }
                    }
                    .disabled(reminderTitle.isEmpty)
                }
                
                // 대기 중인 알림
                Section("예약된 알림 (\(manager.pendingNotifications.count))") {
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
                            Button("삭제", role: .destructive) {
                                manager.cancel(identifier: request.identifier)
                                Task { await manager.fetchPending() }
                            }
                        }
                    }
                    
                    if !manager.pendingNotifications.isEmpty {
                        Button("모두 취소", role: .destructive) {
                            manager.cancelAll()
                            Task { await manager.fetchPending() }
                        }
                    }
                }
            }
            .navigationTitle("알림")
            .task {
                await manager.checkStatus()
                await manager.fetchPending()
            }
        }
    }
}

// MARK: - AppDelegate에서 알림 처리
class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }
    
    // 앱이 foreground일 때 알림 표시
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        return [.banner, .badge, .sound]
    }
    
    // 알림 탭 또는 액션 버튼 처리
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        let userInfo = response.notification.request.content.userInfo
        let actionId = response.actionIdentifier
        
        switch actionId {
        case "COMPLETE":
            // 완료 처리
            if let taskId = userInfo["taskId"] as? String {
                print("Task completed: \(taskId)")
            }
        case "SNOOZE":
            // 10분 뒤 다시 알림
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

## 고급 패턴

### 1. 이미지 첨부

```swift
func scheduleWithImage(imageURL: URL) async throws {
    let content = UNMutableNotificationContent()
    content.title = "사진 알림"
    content.body = "새 사진이 도착했습니다"
    
    let attachment = try UNNotificationAttachment(identifier: "image", url: imageURL, options: nil)
    content.attachments = [attachment]
    
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
    
    try await UNUserNotificationCenter.current().add(request)
}
```

### 2. 커스텀 알림 UI (Notification Content Extension)

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

### 3. 원격 푸시 알림 (APNs)

```swift
// AppDelegate
func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
    print("Device Token: \(token)")
    // 서버로 토큰 전송
}

func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    print("APNs 등록 실패: \(error)")
}

// 등록 요청
UIApplication.shared.registerForRemoteNotifications()
```

## 주의사항

1. **권한 요청 타이밍**
   - 앱 첫 실행 시 바로 요청 ❌
   - 알림이 필요한 기능 사용 직전 요청 ✅

2. **알림 식별자**
   - 같은 식별자로 등록하면 기존 알림 덮어씀
   - 업데이트 가능한 알림에 활용

3. **배지 관리**
   ```swift
   // 배지 설정
   try await center.setBadgeCount(5)
   
   // 배지 초기화 (앱 열 때)
   try await center.setBadgeCount(0)
   ```

4. **시뮬레이터 제한**
   - 원격 푸시 알림은 실제 기기에서만 테스트 가능
   - 로컬 알림은 시뮬레이터에서 가능
