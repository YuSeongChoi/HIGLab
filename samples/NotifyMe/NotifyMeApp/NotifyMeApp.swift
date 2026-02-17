import SwiftUI
import UserNotifications

// MARK: - NotifyMe 앱 진입점
// User Notifications 프레임워크를 활용한 알림 관리 앱입니다.
// 로컬 알림 스케줄링, 카테고리 액션, 히스토리 관리 등을 데모합니다.

@main
struct NotifyMeApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var notificationStore = NotificationStore()
    @StateObject private var settingsManager = SettingsManager.shared
    @StateObject private var historyStore = NotificationHistoryStore.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(notificationStore)
                .environmentObject(settingsManager)
                .environmentObject(historyStore)
        }
    }
}

// MARK: - App Delegate
// 알림 관련 델리게이트 처리를 담당합니다.

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // 알림 센터 델리게이트 설정
        UNUserNotificationCenter.current().delegate = self
        
        // 카테고리 등록
        Task {
            await NotificationService.shared.registerCategories()
        }
        
        return true
    }
    
    // MARK: - 푸시 알림 등록
    
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        // 디바이스 토큰을 서버에 전송 (실제 앱에서 구현)
        let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("📱 디바이스 토큰: \(tokenString)")
    }
    
    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("❌ 푸시 등록 실패: \(error.localizedDescription)")
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    
    /// 앱이 포그라운드일 때 알림 표시 방법 결정
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        // 포그라운드에서도 알림 표시
        return [.banner, .sound, .badge, .list]
    }
    
    /// 사용자가 알림을 탭하거나 액션 버튼을 선택했을 때
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        let userInfo = response.notification.request.content.userInfo
        let actionIdentifier = response.actionIdentifier
        
        // 알림 ID 추출
        guard let notificationIdString = userInfo["id"] as? String,
              let notificationId = UUID(uuidString: notificationIdString)
        else { return }
        
        // 히스토리에서 열림 상태 업데이트
        await MainActor.run {
            NotificationHistoryStore.shared.markAsOpened(id: notificationId)
        }
        
        // 액션 처리
        switch actionIdentifier {
        case UNNotificationDefaultActionIdentifier:
            // 기본 탭 동작 - 앱 열기
            print("📲 알림 탭: \(notificationId)")
            
        case UNNotificationDismissActionIdentifier:
            // 알림 무시
            print("👋 알림 무시: \(notificationId)")
            
        case NotificationAction.snooze10.rawValue:
            await handleSnooze(notificationId: notificationId, minutes: 10)
            
        case NotificationAction.snooze30.rawValue:
            await handleSnooze(notificationId: notificationId, minutes: 30)
            
        case NotificationAction.complete.rawValue,
             NotificationAction.done.rawValue,
             NotificationAction.arrived.rawValue:
            await handleComplete(notificationId: notificationId)
            
        case NotificationAction.skip.rawValue:
            print("⏭️ 건너뛰기: \(notificationId)")
            
        case NotificationAction.open.rawValue,
             NotificationAction.reply.rawValue,
             NotificationAction.navigate.rawValue:
            // 앱을 열고 해당 기능으로 이동
            print("🚀 액션 열기: \(actionIdentifier)")
            
        default:
            print("❓ 알 수 없는 액션: \(actionIdentifier)")
        }
    }
    
    // MARK: - 액션 핸들러
    
    /// 다시 알림 처리
    private func handleSnooze(notificationId: UUID, minutes: Int) async {
        // 기존 알림 정보를 기반으로 새 알림 스케줄
        let snoozeDate = Date().addingTimeInterval(TimeInterval(minutes * 60))
        let snoozeItem = NotificationItem(
            title: "다시 알림",
            body: "\(minutes)분 전 알림의 다시 알림입니다",
            scheduledDate: snoozeDate,
            repeatInterval: .none,
            category: .reminder
        )
        
        do {
            try await NotificationService.shared.scheduleTimeBasedNotification(snoozeItem)
            print("⏰ \(minutes)분 후 다시 알림 설정")
        } catch {
            print("❌ 다시 알림 설정 실패: \(error)")
        }
    }
    
    /// 완료 처리
    private func handleComplete(notificationId: UUID) async {
        // 알림 저장소에서 해당 알림 비활성화
        await MainActor.run {
            NotificationStore.shared.toggleNotification(id: notificationId, isEnabled: false)
        }
        print("✅ 완료 처리: \(notificationId)")
    }
}

// MARK: - 알림 저장소
// 앱 내 알림 목록을 관리하는 저장소

@MainActor
class NotificationStore: ObservableObject {
    static let shared = NotificationStore()
    
    @Published var notifications: [NotificationItem] = []
    
    private let storageKey = "ScheduledNotifications"
    
    init() {
        loadNotifications()
        
        // 초기 데이터가 없으면 샘플 데이터 로드
        if notifications.isEmpty {
            notifications = NotificationItem.previewList
            saveNotifications()
        }
    }
    
    // MARK: - CRUD
    
    /// 알림 추가
    func addNotification(_ item: NotificationItem) {
        notifications.append(item)
        saveNotifications()
        
        // 실제 알림 스케줄링
        Task {
            try? await NotificationService.shared.scheduleTimeBasedNotification(item)
        }
    }
    
    /// 알림 수정
    func updateNotification(_ item: NotificationItem) {
        guard let index = notifications.firstIndex(where: { $0.id == item.id }) else { return }
        
        // 기존 알림 취소
        Task {
            await NotificationService.shared.cancelNotification(id: item.id)
        }
        
        notifications[index] = item
        saveNotifications()
        
        // 새 알림 스케줄링
        if item.isEnabled {
            Task {
                try? await NotificationService.shared.scheduleTimeBasedNotification(item)
            }
        }
    }
    
    /// 알림 삭제
    func deleteNotification(id: UUID) {
        notifications.removeAll { $0.id == id }
        saveNotifications()
        
        Task {
            await NotificationService.shared.cancelNotification(id: id)
        }
    }
    
    /// 알림 활성화/비활성화
    func toggleNotification(id: UUID, isEnabled: Bool) {
        guard let index = notifications.firstIndex(where: { $0.id == id }) else { return }
        
        notifications[index].isEnabled = isEnabled
        saveNotifications()
        
        Task {
            if isEnabled {
                try? await NotificationService.shared.scheduleTimeBasedNotification(notifications[index])
            } else {
                await NotificationService.shared.cancelNotification(id: id)
            }
        }
    }
    
    // MARK: - 저장/불러오기
    
    private func saveNotifications() {
        guard let data = try? JSONEncoder().encode(notifications) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }
    
    private func loadNotifications() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let items = try? JSONDecoder().decode([NotificationItem].self, from: data)
        else { return }
        notifications = items
    }
}
